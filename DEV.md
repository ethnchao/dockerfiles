# 开发说明（DEV）

## 仓库结构

```
dockerfiles/
├── common/                     # 通用初始化脚本（不会进入镜像层）
│   ├── common-setup.sh         # 主入口，统一调用各子脚本
│   ├── setup-apt-mirror.sh     # Debian/Ubuntu apt 源 → 阿里云
│   ├── setup-yum-mirror.sh     # CentOS/RHEL yum 源 → 阿里云
│   ├── setup-apk-mirror.sh     # Alpine apk 源 → 阿里云
│   ├── setup-npm-mirror.sh     # npm/yarn/pnpm 源 → npmmirror
│   ├── setup-timezone.sh       # 时区设置（/etc/localtime）
│   ├── install-tools.sh        # 安装 vim / ping / nslookup / netstat 等
│   └── setup-vim.sh            # 写入 vim 全局配置
├── images/                     # 各镜像子目录
│   ├── ubuntu/
│   │   └── Dockerfile
│   ├── nginx/
│   │   └── Dockerfile
│   └── node/
│       └── Dockerfile
├── docker-bake.hcl             # 批量构建入口（变量 + 并行）
├── docker-compose.yaml         # 本地测试用
├── README.md                   # 镜像列表与快速开始
└── DEV.md                      # 本文件：开发规范
```

## 核心设计原则

### 1. 构建上下文始终为仓库根目录

所有 Dockerfile 的 `context` 都设置为 `.`（仓库根），这是 `bind mount` 能读取 `common/` 的前提。  
通过 `docker-bake.hcl` 中的 `target._common.context = "."` 统一保证，**不要**在子目录单独运行 `docker build`。

### 2. 通用脚本通过 bind mount 引入，零层数开销

```dockerfile
# syntax=docker/dockerfile:1

RUN --mount=type=bind,source=common,target=/tmp/common \
    sh /tmp/common/common-setup.sh
```

`--mount=type=bind` 是 BuildKit 特性，脚本在构建时可见，但不会被 COPY 进镜像，不增加层数。  
需要 Docker 23.0+ 或 `DOCKER_BUILDKIT=1` 环境变量（推荐前者）。

### 3. 按需跳过通用步骤

`common-setup.sh` 通过环境变量控制执行的步骤：

```dockerfile
RUN --mount=type=bind,source=common,target=/tmp/common \
    SKIP_MIRROR_YUM=true \
    SKIP_MIRROR_APK=true \
    sh /tmp/common/common-setup.sh
```

| 环境变量 | 说明 | 默认 |
|----------|------|------|
| `SKIP_MIRROR_APT` | 跳过 apt 源配置 | `false` |
| `SKIP_MIRROR_YUM` | 跳过 yum 源配置 | `false` |
| `SKIP_MIRROR_APK` | 跳过 apk 源配置 | `false` |
| `SKIP_MIRROR_NPM` | 跳过 npm 源配置 | `false` |
| `SKIP_TIMEZONE` | 跳过时区设置 | `false` |
| `SKIP_TOOLS` | 跳过工具安装 | `false` |
| `SKIP_VIM` | 跳过 vim 配置 | `false` |

### 4. 添加新镜像的步骤

1. 在 `images/` 下新建目录，例如 `images/redis/`
2. 编写 `Dockerfile`，首行加 `# syntax=docker/dockerfile:1`，用 bind mount 引入 common
3. 在 `docker-bake.hcl` 中新增 `target` 块，并加入对应 `group.targets`
4. 在 `docker-compose.yaml` 中新增 service 用于本地测试
5. 更新 `README.md` 镜像列表

### 5. 镜像仓库变量

通过 `REGISTRY` 环境变量切换目标仓库，无需改动任何文件：

```bash
# 推送到阿里云（默认）
docker buildx bake --push

# 推送到内部 Harbor
REGISTRY=harbor.mcdchina.net/devops-public docker buildx bake --push
```

## 本地构建前置条件

```bash
# 检查 BuildKit 是否可用
docker buildx version

# 创建支持多平台的 builder（首次使用）
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap
```

## CI/CD（GitHub Actions）

流水线配置：`.github/workflows/build-push.yml`，随代码版本管理。

### 首次接入步骤

1. **配置 Secrets**（仓库 Settings → Secrets and variables → Actions → New repository secret）：

   | Secret | 说明 |
   |--------|------|
   | `REGISTRY_USERNAME` | 镜像仓库登录用户名 |
   | `REGISTRY_PASSWORD` | 镜像仓库登录密码 |

2. **配置 Variables**（同页面 Variables 标签，非敏感信息）：

   | Variable | 默认值 | Harbor 切换示例 |
   |----------|--------|----------------|
   | `REGISTRY` | `registry.cn-hangzhou.aliyuncs.com/onemanstudio` | `harbor.mcdchina.net/devops-public` |
   | `REGISTRY_HOST` | `registry.cn-hangzhou.aliyuncs.com` | `harbor.mcdchina.net` |

   > Variables 留空时 workflow 文件中的默认值生效，无需强制配置。

3. **触发方式**：
   - push 到 `main` 分支自动触发，Tag 使用 git short SHA
   - 在 Actions 页面手动触发（workflow_dispatch），可指定 `registry` 和 `tag`

### 流水线步骤说明

| 步骤 | 说明 |
|------|------|
| 检出代码 | `actions/checkout@v4` |
| 确定 Tag | 手动指定优先，否则取 git commit SHA 前 8 位 |
| 设置 QEMU | 支持 arm64 等跨平台模拟 |
| 设置 buildx | `docker-container` driver，原生支持多平台 |
| 登录仓库 | `docker/login-action@v3`，凭据来自 Secrets |
| 构建推送 | `docker buildx bake --push`，并行构建全部镜像（amd64 + arm64）|
| 构建摘要 | 写入 GitHub Actions Summary 页面 |

## 注意事项

- 所有 shell 脚本使用 `#!/bin/sh` 而非 `#!/bin/bash`，保证 Alpine 兼容性
- `setup-vim.sh` 依赖 `/etc/vim/` 目录，Alpine 中 vim 包会自动创建该目录
- `setup-npm-mirror.sh` 写入 `/etc/npmrc` 作为全局配置，无需针对单个用户设置
