# ClearCraftManager

<div align="center">
  <br />
  <br />

[![--](https://img.shields.io/badge/Support-Windows/Linux-green.svg)](https://github.com/XiaoWu-ClearCraft/ClearCraftManager)
[![Status](https://img.shields.io/badge/npm-v8.9.14-blue.svg)](https://www.npmjs.com/)
[![Status](https://img.shields.io/badge/node-v16.20.2-blue.svg)](https://nodejs.org/en/download/)
[![Status](https://img.shields.io/badge/License-Apache%202.0-red.svg)](https://www.apache.org/licenses/LICENSE-2.0)

</div>

## 这是什么？

**ClearCraftManager** 是一款基于 **MCSManager** 二次开发的定制化游戏服务器管理面板，专为 **ClearCraft** 服务器的运行所设计。

ClearCraftManager 是一款支持分布式架构、多用户、现代化的 Web 管理面板，支持 **Minecraft**、**Steam** 等游戏服务器。它继承了 MCSManager 的核心能力，并增加了原生 **Podman** 容器后端支持。

> 本项目是基于 [MCSManager](https://github.com/MCSManager/MCSManager) 的衍生项目（Fork），**与 MCSManager 官方团队无关**。ClearCraft 保留对所更改和新增代码的所有权。

<br />

## 功能特性

1. 使用应用市场一键部署游戏服务器。
2. 兼容大部分 **Steam** 游戏服务器。
3. 网页支持拖拽式小卡片布局，自定义界面。
4. 支持 **Docker** 和 **Podman** 容器镜像，支持切换容器后端。
5. 支持分布式架构，一个网页管理多台机器。
6. 多用户权限系统。
7. 更多...

<br />

## 运行环境

- 需安装 [Node.js 16.20.2](https://nodejs.org/en) 以上（推荐最新 LTS 版本）。
- 支持 **Windows**、**Linux**、**macOS**。

<br />

## 快速开始

### Windows

下载最新发行版，双击 `start.bat` 即可启动。

### Linux

```bash
# 一行命令快速安装
sudo su -c "wget -qO- https://raw.githubusercontent.com/XiaoWu-ClearCraft/ClearCraftManager/master/setup.sh | bash"

# 安装后使用方法
systemctl start ccmang-{web,daemon}
```

### 手动安装

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

# 启动节点程序
./start-daemon.sh

# 启动面板程序（在另一个终端）
./start-web.sh

# 访问 http://<你的IP>:23333/
```

<br />

## 容器后端支持

ClearCraftManager 支持 **Docker** 和 **Podman** 两种容器后端。

- 在 **设置 → 基础信息 → 容器后端** 中设置全局默认值
- 在 **节点管理 → 高级配置 → 容器后端** 中为单个节点单独配置
- 支持的 socket 路径：
  - Docker Linux: `/var/run/docker.sock`
  - Podman rootful: `/run/podman/podman.sock`
  - Podman rootless: `$XDG_RUNTIME_DIR/podman/podman.sock`
  - `DOCKER_HOST` 环境变量始终优先

<br />

## 开发

### 项目结构

- `daemon/` - 节点端（进程管理、Docker/Podman 操作、文件管理）
- `panel/` - 网页后端（用户管理、节点连接、API 服务）
- `frontend/` - 网页前端（Vue 3、Vite）
- `common/` - 公共库
- `languages/` - 国际化文件

<br />

## 许可证

本项目遵循 [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) 协议。

- 原始代码来源于 [MCSManager](https://github.com/MCSManager/MCSManager)，Copyright &copy; MCSManager。
- 修改和新增代码归 ClearCraft 所有。

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
