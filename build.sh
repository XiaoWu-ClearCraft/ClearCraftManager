#!/bin/sh

set -e

BASE_PATH=$(pwd)
OUTPUT_DIR="clearcraftmanager"
OUTPUT_ARCHIVE="${OUTPUT_DIR}_linux_release.tar.gz"
CACHE_DIR="${BASE_PATH}/.build-cache"

mkdir -p "${CACHE_DIR}/lib"
mkdir -p "${CACHE_DIR}/hashes"

compute_hash() {
  find "$1" -type f \( -name '*.ts' -o -name '*.vue' -o -name '*.js' -o -name '*.mjs' -o -name '*.json' \) \
    ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/production/*' \
    ! -name 'package.json' | sort | xargs -d '\n' sha256sum 2>/dev/null | sha256sum | cut -d' ' -f1
}

check_cache() {
  local name="$1"
  local hash_file="${CACHE_DIR}/hashes/${name}"
  local current_hash="$2"
  if [ -f "${hash_file}" ] && [ "$(cat "${hash_file}")" = "${current_hash}" ]; then
    return 0
  fi
  return 1
}

save_cache() {
  local name="$1"
  local hash_file="${CACHE_DIR}/hashes/${name}"
  local current_hash="$2"
  echo "$current_hash" > "${hash_file}"
}

needs_rebuild() {
  local name="$1"
  local src_dir="$2"
  local output_dir="$3"
  local hash=$(compute_hash "${src_dir}")
  if ! check_cache "${name}" "${hash}" || [ ! -f "${output_dir}" ]; then
    echo "${hash}" > /tmp/.rebuild_hash_${name}
    # Clean previous output for this component
    case "${name}" in
      common)  rm -rf "${BASE_PATH}/common/dist" ;;
      daemon)  rm -rf "${BASE_PATH}/daemon/dist" "${BASE_PATH}/daemon/production" ;;
      panel)   rm -rf "${BASE_PATH}/panel/dist" "${BASE_PATH}/panel/production" ;;
      frontend) rm -rf "${BASE_PATH}/frontend/dist" ;;
    esac
    return 0
  fi
  return 1
}

mark_rebuilt() {
  local name="$1"
  if [ -f "/tmp/.rebuild_hash_${name}" ]; then
    save_cache "${name}" "$(cat /tmp/.rebuild_hash_${name})"
    rm -f "/tmp/.rebuild_hash_${name}"
  fi
}

# If version arguments are provided, update package.json versions
if [ -n "$1" ]; then
  WEB_VERSION="$1"
  echo "Setting web version to ${WEB_VERSION}..."
  sed -i "s/\"version\": \".*\"/\"version\": \"${WEB_VERSION}\"/" "${BASE_PATH}/panel/package.json"
else
  WEB_VERSION=$(grep '"version"' "${BASE_PATH}/panel/package.json" | sed 's/.*"version": "\(.*\)".*/\1/')
fi

if [ -n "$2" ]; then
  DAEMON_VERSION="$2"
  echo "Setting daemon version to ${DAEMON_VERSION}..."
  sed -i "s/\"version\": \".*\"/\"version\": \"${DAEMON_VERSION}\"/" "${BASE_PATH}/daemon/package.json"
  sed -i "s/\"daemonVersion\": \".*\"/\"daemonVersion\": \"${DAEMON_VERSION}\"/" "${BASE_PATH}/panel/package.json"
else
  DAEMON_VERSION=$(grep '"version"' "${BASE_PATH}/daemon/package.json" | sed 's/.*"version": "\(.*\)".*/\1/')
fi

rm -rf ${OUTPUT_DIR}

echo "Build common..."
cd "${BASE_PATH}/common"
npm install --no-fund --no-audit
if needs_rebuild "common" "${BASE_PATH}/common/src" "${BASE_PATH}/common/dist/index.js"; then
  npm run build
  mark_rebuilt "common"
else
  echo "  No changes detected, using previous build."
fi

echo "Build daemon..."
cd "${BASE_PATH}/daemon"
if needs_rebuild "daemon" "${BASE_PATH}/daemon/src" "${BASE_PATH}/daemon/production/app.js"; then
  npm run build
  mark_rebuilt "daemon"
else
  echo "  No changes detected, using previous build."
fi

echo "Build panel..."
cd "${BASE_PATH}/panel"
if needs_rebuild "panel" "${BASE_PATH}/panel/src" "${BASE_PATH}/panel/production/app.js"; then
  npm run build
  mark_rebuilt "panel"
else
  echo "  No changes detected, using previous build."
fi

echo "Build frontend..."
cd "${BASE_PATH}/frontend"
if needs_rebuild "frontend" "${BASE_PATH}/frontend/src" "${BASE_PATH}/frontend/dist/index.html"; then
  npm run build
  mark_rebuilt "frontend"
else
  echo "  No changes detected, using previous build."
fi

echo "Collecting files..."
cd "${BASE_PATH}"

mkdir -p ${OUTPUT_DIR}/daemon
mkdir -p ${OUTPUT_DIR}/web
mkdir -p ${OUTPUT_DIR}/web/public

cp -r "${BASE_PATH}/daemon/production/app.js" "${BASE_PATH}/${OUTPUT_DIR}/daemon"
cp -r "${BASE_PATH}/daemon/production/app.js.map" "${BASE_PATH}/${OUTPUT_DIR}/daemon"
cp -f "${BASE_PATH}/daemon/package.json" "${BASE_PATH}/${OUTPUT_DIR}/daemon/package.json"
cp -f "${BASE_PATH}/daemon/package-lock.json" "${BASE_PATH}/${OUTPUT_DIR}/daemon/package-lock.json"

# Copy daemon lib (native binaries) if exists
if [ -d "${BASE_PATH}/daemon/lib" ]; then
  cp -r "${BASE_PATH}/daemon/lib" "${BASE_PATH}/${OUTPUT_DIR}/daemon/lib"
fi

cp -r "${BASE_PATH}/panel/production/app.js" "${BASE_PATH}/${OUTPUT_DIR}/web"
cp -r "${BASE_PATH}/panel/production/app.js.map" "${BASE_PATH}/${OUTPUT_DIR}/web"
cp -f "${BASE_PATH}/panel/package.json" "${BASE_PATH}/${OUTPUT_DIR}/web/package.json"
cp -f "${BASE_PATH}/panel/package-lock.json" "${BASE_PATH}/${OUTPUT_DIR}/web/package-lock.json"

cp -r "${BASE_PATH}"/frontend/dist/* "${BASE_PATH}/${OUTPUT_DIR}/web/public"

cd "${BASE_PATH}/${OUTPUT_DIR}/daemon"
npm install --production --no-fund --no-audit --prefer-offline
cd "${BASE_PATH}/${OUTPUT_DIR}/web"
npm install --production --no-fund --no-audit --prefer-offline

cd "${BASE_PATH}"

# Download native binary dependencies (PTY, Zip-Tools, 7z) with caching
echo "Checking native binary dependencies..."
mkdir -p "${OUTPUT_DIR}/daemon/lib"

LIB_HASH_FILE="${CACHE_DIR}/lib-urls.hash"
LIB_HASH_CURRENT=$(sha256sum "${BASE_PATH}/lib-urls.txt" | cut -d' ' -f1)
LIB_HASH_CACHED=""
[ -f "${LIB_HASH_FILE}" ] && LIB_HASH_CACHED=$(cat "${LIB_HASH_FILE}")

if [ "${LIB_HASH_CACHED}" = "${LIB_HASH_CURRENT}" ] && [ -d "${CACHE_DIR}/lib" ] && [ "$(ls -A "${CACHE_DIR}/lib")" ]; then
  echo "  lib-urls.txt unchanged, using cached binaries."
  cp -r "${CACHE_DIR}/lib/"* "${OUTPUT_DIR}/daemon/lib/"
else
  echo "  lib-urls.txt changed or cache empty, downloading binaries..."
  while IFS= read -r url || [ -n "$url" ]; do
    url=$(echo "$url" | tr -d '\r\n')
    [ -z "$url" ] && continue
    filename=$(basename "$url")
    echo "  Downloading $filename..."
    if command -v curl >/dev/null 2>&1; then
      curl -fSL "$url" -o "${CACHE_DIR}/lib/$filename" || {
        echo "  Error: Failed to download $filename"
        exit 1
      }
    elif command -v wget >/dev/null 2>&1; then
      wget -q "$url" -O "${CACHE_DIR}/lib/$filename" || {
        echo "  Error: Failed to download $filename"
        exit 1
      }
    else
      echo "  Error: Neither curl nor wget found. Cannot download dependencies."
      exit 1
    fi
  done < "${BASE_PATH}/lib-urls.txt"
  cp -r "${CACHE_DIR}/lib/"* "${OUTPUT_DIR}/daemon/lib/"
  echo "${LIB_HASH_CURRENT}" > "${LIB_HASH_FILE}"
fi

# Create start-daemon.sh
cat > "${OUTPUT_DIR}/start-daemon.sh" << 'EOF'
#!/bin/bash
cd daemon || exit
node --max-old-space-size=8192 --enable-source-maps app.js
EOF

# Create start-web.sh
cat > "${OUTPUT_DIR}/start-web.sh" << 'EOF'
#!/bin/bash
cd web || exit
node --max-old-space-size=8192 --enable-source-maps app.js
EOF

# Create install.sh
cat > "${OUTPUT_DIR}/install.sh" << 'EOF'
#!/bin/bash
BASE_PATH=$(pwd)
cd "${BASE_PATH}/daemon" && npm install --production --no-fund --no-audit --prefer-offline
cd "${BASE_PATH}/web" && npm install --production --no-fund --no-audit --prefer-offline
echo "------------"
echo "All done!"
echo "------------"
EOF

# Copy LICENSE
cp -f "${BASE_PATH}/LICENSE" "${BASE_PATH}/${OUTPUT_DIR}/LICENSE"

chmod +x ${OUTPUT_DIR}/start-daemon.sh
chmod +x ${OUTPUT_DIR}/start-web.sh
chmod +x ${OUTPUT_DIR}/install.sh

# Create release archive
echo "Packaging ${OUTPUT_ARCHIVE}..."
tar -czf "${BASE_PATH}/${OUTPUT_ARCHIVE}" -C "${BASE_PATH}" "${OUTPUT_DIR}"

echo "------------"
echo "Compilation completed!"
echo "Web Version: ${WEB_VERSION}"
echo "Daemon Version: ${DAEMON_VERSION}"
echo "Output Directory: ./${OUTPUT_DIR}/"
echo "Release Archive: ./${OUTPUT_ARCHIVE}"
echo "------------"
