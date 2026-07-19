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

<br />

## Development

### Project Structure

- `daemon/` - Daemon backend (process management, Docker/Podman operations, file system)
- `panel/` - Web backend (user management, node connectivity, API services)
- `frontend/` - Web frontend (Vue 3, Vite)
- `common/` - Shared library
- `languages/` - Internationalization files

<br />

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
