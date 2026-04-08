# Dockerfiles Monorepo

个人 Docker 镜像二次封装仓库。对常用开源镜像进行标准化改造：切换国内源、设置时区、安装调试工具，统一管理构建配置。

## 镜像列表

| 镜像名 | 基础镜像 | 用途 |
|--------|----------|------|
| `ubuntu` | `ubuntu:22.04` | 通用 Ubuntu 基础层，适合作为其他自定义镜像的 FROM 来源 |
| `nginx` | `nginx:alpine` | 生产级 Nginx，内置调试工具、已配置阿里云 apk 源和 Asia/Shanghai 时区 |
| `node` | `node:20-bullseye-slim` | Node.js 20 LTS，npm/yarn/pnpm 已切换 npmmirror，适合 CI 构建和应用运行 |

## 公共特性（通用封装）

所有镜像均包含以下改造：

- **软件源**：根据基础系统自动切换为阿里云镜像（apt / yum / apk）
- **时区**：写入 `/etc/localtime` 和 `/etc/timezone`，设置为 `Asia/Shanghai`（非环境变量）
- **常用工具**：`vim`、`ping`、`nslookup`、`netstat`、`curl`、`wget`、`procps`
- **vim 配置**：写入 `/etc/vim/vimrc.local`，支持行号、语法高亮、搜索高亮等

Node 镜像额外包含：
- **npm 镜像**：npm / yarn / pnpm 源均设置为 `https://registry.npmmirror.com`

## 镜像仓库

| 标识 | 地址 |
|------|------|
| 阿里云（默认） | `registry.cn-hangzhou.aliyuncs.com/onemanstudio` |
| 内部 Harbor | `harbor.mcdchina.net/devops-public` |

切换仓库：`export REGISTRY=harbor.mcdchina.net/devops-public`

## 快速开始

```bash
# 构建并推送所有镜像（阿里云仓库）
docker buildx bake --push

# 构建单个镜像并加载到本地
docker buildx bake nginx --set "*.output=type=docker"

# 切换目标仓库
REGISTRY=harbor.mcdchina.net/devops-public docker buildx bake --push

# 指定版本 tag
TAG=20240101 docker buildx bake --push

# 本地一键构建 + 启动测试
docker compose up -d
```
