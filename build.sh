#!/bin/sh

set -e

BASE_PATH=$(pwd)
OUTPUT_DIR="clearcraftmanager"
OUTPUT_ARCHIVE="${OUTPUT_DIR}_linux_release.tar.gz"

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
else
  DAEMON_VERSION=$(grep '"version"' "${BASE_PATH}/daemon/package.json" | sed 's/.*"version": "\(.*\)".*/\1/')
fi

npm run preview-build

rm -rf ${OUTPUT_DIR}
rm -rf ./daemon/dist ./daemon/production
rm -rf ./panel/dist ./panel/production

echo "Build daemon..."
cd "${BASE_PATH}/daemon"
npm run build

echo "Build panel..."
cd "${BASE_PATH}/panel"
npm run build

echo "Build frontend..."
cd "${BASE_PATH}/frontend"
npm run build

echo "Collecting files..."
cd "${BASE_PATH}"

mkdir -p ${OUTPUT_DIR}/daemon
mkdir -p ${OUTPUT_DIR}/web
mkdir -p ${OUTPUT_DIR}/web/public

mv "${BASE_PATH}/daemon/production/app.js" "${BASE_PATH}/${OUTPUT_DIR}/daemon"
mv "${BASE_PATH}/daemon/production/app.js.map" "${BASE_PATH}/${OUTPUT_DIR}/daemon"
cp -f "${BASE_PATH}/daemon/package.json" "${BASE_PATH}/${OUTPUT_DIR}/daemon/package.json"
cp -f "${BASE_PATH}/daemon/package-lock.json" "${BASE_PATH}/${OUTPUT_DIR}/daemon/package-lock.json"

# Copy daemon lib (native binaries) if exists
if [ -d "${BASE_PATH}/daemon/lib" ]; then
  cp -r "${BASE_PATH}/daemon/lib" "${BASE_PATH}/${OUTPUT_DIR}/daemon/lib"
fi

mv "${BASE_PATH}/panel/production/app.js" "${BASE_PATH}/${OUTPUT_DIR}/web"
mv "${BASE_PATH}/panel/production/app.js.map" "${BASE_PATH}/${OUTPUT_DIR}/web"
cp -f "${BASE_PATH}/panel/package.json" "${BASE_PATH}/${OUTPUT_DIR}/web/package.json"
cp -f "${BASE_PATH}/panel/package-lock.json" "${BASE_PATH}/${OUTPUT_DIR}/web/package-lock.json"

mv "${BASE_PATH}"/frontend/dist/* "${BASE_PATH}/${OUTPUT_DIR}/web/public"

rm -rf "${BASE_PATH}/daemon/dist" "${BASE_PATH}/daemon/production"
rm -rf "${BASE_PATH}/panel/dist" "${BASE_PATH}/panel/production"
rm -rf "${BASE_PATH}/frontend/dist"

cd "${BASE_PATH}/${OUTPUT_DIR}/daemon"
npm install --production --no-fund --no-audit
cd "${BASE_PATH}/${OUTPUT_DIR}/web"
npm install --production --no-fund --no-audit

cd "${BASE_PATH}"

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
cd "${BASE_PATH}/daemon" && npm install --production --no-fund --no-audit
cd "${BASE_PATH}/web" && npm install --production --no-fund --no-audit
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
