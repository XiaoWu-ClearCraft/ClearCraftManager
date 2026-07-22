# ClearCraftManager

<div align="center">
  <br />
  <br />

[![--](https://img.shields.io/badge/Support%20Platform-Windows/Linux/Mac-green.svg)](https://github.com/XiaoWu-ClearCraft/ClearCraftManager)
[![Status](https://img.shields.io/badge/NPM-v8.9.14-blue.svg)](https://www.npmjs.com/)
[![Status](https://img.shields.io/badge/Node-v16.20.2-blue.svg)](https://nodejs.org/en/download/)
[![Status](https://img.shields.io/badge/License-Apache%202.0-red.svg)](https://www.apache.org/licenses/LICENSE-2.0)

</div>

## What is this?

**ClearCraftManager** is a customized game server management panel based on **MCSManager** secondary development, specifically designed for the operation of **ClearCraft** servers.

ClearCraftManager is a web-based, multi-user, distributed management panel that supports **Minecraft**, **Steam**, and other game servers. It inherits the core capabilities of MCSManager and adds native **Podman** container backend support.

> This project is a fork of [MCSManager](https://github.com/MCSManager/MCSManager) and is **not affiliated with the MCSManager official team**. ClearCraft retains ownership of all modified and added code.

<br />

## Features

1. One-click deployment of game servers via the built-in application marketplace.
2. Support for most **Steam**-based game servers.
3. Customizable web interface with drag-and-drop card layout.
4. Full **Docker** and **Podman** container image support, with switchable container backend.
5. Distributed architecture, managing multiple machines from a single web panel.
6. Multi-user permission system.
7. ...and more.

<br />

## Runtime Environment

- Requires **[Node.js 16.20.2](https://nodejs.org/en)** or higher (latest LTS recommended).
- Supports **Windows**, **Linux**, and **macOS**.

<br />

## Quick Start

### Windows

Download the latest release and double-click `start.bat`.

### Linux

```bash
# One-line command quick installation
sudo su -c "wget -qO- https://raw.githubusercontent.com/XiaoWu-ClearCraft/ClearCraftManager/master/setup.sh | bash"

# After installation
systemctl start ccmang-{web,daemon}
```

### Manual Installation

```bash
cd /opt/
wget https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz
tar -xvf node-v20.11.0-linux-x64.tar.xz
ln -s /opt/node-v20.11.0-linux-x64/bin/node /usr/bin/node
ln -s /opt/node-v20.11.0-linux-x64/bin/npm /usr/bin/npm

mkdir -p /opt/clearcraftmanager/
cd /opt/clearcraftmanager/
wget https://github.com/XiaoWu-ClearCraft/ClearCraftManager/releases/latest/download/clearcraftmanager_linux_release.tar.gz || \
wget https://gh.xmly.dev/https://github.com/XiaoWu-ClearCraft/ClearCraftManager/releases/latest/download/clearcraftmanager_linux_release.tar.gz
tar -zxf clearcraftmanager_linux_release.tar.gz
chmod 775 install.sh
./install.sh

# Start daemon
./start-daemon.sh

# Start web service (in another terminal)
./start-web.sh

# Access: http://<your-ip>:23333/
```

<br />

## Container Backend Support

ClearCraftManager supports both **Docker** and **Podman** as container backends.

- Set the global default in **Settings → Basic Info → Container Backend**
- Configure per-node in **Node Management → Advanced Settings → Container Backend**
- Supported socket paths:
  - Docker Linux: `/var/run/docker.sock`
  - Podman rootful: `/run/podman/podman.sock`
  - Podman rootless: `$XDG_RUNTIME_DIR/podman/podman.sock`
  - The `DOCKER_HOST` environment variable always takes precedence

### Docker Compose Deployment

```yml
services:
  web:
    image: githubyumao/mcsmanager-web:latest
    ports:
      - "23333:23333"
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - <CHANGE_ME_TO_INSTALL_PATH>/web/data:/opt/mcsmanager/web/data
      - <CHANGE_ME_TO_INSTALL_PATH>/web/logs:/opt/mcsmanager/web/logs
      - <CHANGE_ME_TO_INSTALL_PATH>/web/public/upload_files:/opt/mcsmanager/web/public/upload_files

  daemon:
    image: githubyumao/mcsmanager-daemon:latest
    restart: unless-stopped
    ports:
      - "24444:24444"
    environment:
      - MCSM_DOCKER_WORKSPACE_PATH=<CHANGE_ME_TO_INSTALL_PATH>/daemon/data/InstanceData
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - <CHANGE_ME_TO_INSTALL_PATH>/daemon/data:/opt/mcsmanager/daemon/data
      - <CHANGE_ME_TO_INSTALL_PATH>/daemon/logs:/opt/mcsmanager/daemon/logs
      - /var/run/docker.sock:/var/run/docker.sock
```

Note (Rootless Docker on Linux): the daemon supports `DOCKER_HOST`. If your Docker daemon runs in rootless mode, the socket is usually at `/run/user/<uid>/docker.sock` instead of `/var/run/docker.sock`. In that case, replace the default socket mount with the rootless socket and set `DOCKER_HOST`, for example:

```yml
daemon:
  environment:
    - DOCKER_HOST=unix:///run/user/1000/docker.sock
  volumes:
    - /run/user/1000/docker.sock:/run/user/1000/docker.sock
```

Replace `1000` with your actual UID (`id -u`).

Enable using docker-compose.

```bash
mkdir -p <CHANGE_ME_TO_INSTALL_PATH>
cd <CHANGE_ME_TO_INSTALL_PATH>
vim docker-compose.yml
docker compose pull && docker compose up -d
```

Note: After Docker installation, the Web side may no longer be able to automatically connect to the Daemon. You need to create a new node to connect them together.

<br />

## Contributing Code

Before contributing code to this project, please make sure to review the following:

- **Must read:** [Issue #599 – Contribution Guidelines](https://github.com/MCSManager/MCSManager/issues/599)
- Please maintain the existing code structure and formatting, **do not apply unnecessary or excessive formatting changes.**
- All submitted code **must follow internationalization (i18n) standards**.

### Bug Reports

We welcome all bug reports and feedback. Your contributions help us improve the project.

If you encounter any issues, please report them via the [GitHub Issues](https://github.com/MCSManager/MCSManager/issues) page, and we'll address them as soon as possible.

For serious **security vulnerabilities** that should not be disclosed publicly, please contact us directly at: **support@mcsmanager.com**

Once resolved, we will credit the discoverer in the relevant code or release notes.

### Acknowledgements

Thanks to the following developers for making important contributions to the security testing of MCSManager!

> [@Cuo256](https://github.com/Cuo256), [@xiaosu](https://github.com/xiaosuawa), [@tianjiefeifei](https://github.com/tianjiefeifei), [9Bakabaka](https://github.com/9Bakabaka)

<br />

## Development

### Project Structure

- `daemon/` - Daemon backend (process management, Docker/Podman operations, file system)
- `panel/` - Web backend (user management, node connectivity, API services)
- `frontend/` - Web frontend (Vue 3, Vite)
- `common/` - Shared library
- `languages/` - Internationalization files

<br />

## Browser Compatibility

ClearCraftManager supports all major modern browsers, including:

- `Chrome`
- `Firefox`
- `Safari`
- `Opera`

**Internet Explorer (IE)** is no longer supported.
## License

This project is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

- The original codebase is derived from [MCSManager](https://github.com/MCSManager/MCSManager), Copyright &copy; MCSManager.
- Modifications and additions are Copyright &copy; ClearCraft. All rights reserved.

```
Copyright 2025 MCSManager

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
