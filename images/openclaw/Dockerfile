# syntax=docker/dockerfile:1
# OpenClaw 封装镜像
# 基础镜像：ghcr.io/openclaw/openclaw:2026.3.31-slim
# 用途：OpenClaw 应用镜像，已配置阿里云 apt 源、Asia/Shanghai 时区、内置常用调试工具
#       额外预装 gogcli（GOG 命令行工具）

FROM ghcr.io/openclaw/openclaw:2026.3.31-slim

# 原镜像以非 root 用户运行，写系统文件需要先切换到 root
USER root

# ── 通用初始化（apt 源、时区、调试工具） ────────────────────────────────────
RUN --mount=type=bind,source=common,target=/tmp/common \
    SKIP_MIRROR_YUM=true \
    SKIP_MIRROR_APK=true \
    SKIP_MIRROR_NPM=true \
    sh /tmp/common/common-setup.sh

# ── 安装 gogcli ──────────────────────────────────────────────────────────────
# TARGETARCH 由 buildx 自动注入，与 GitHub Release 命名一致（amd64 / arm64）
ARG TARGETARCH
ARG GOGCLI_VERSION=0.12.0

RUN curl -fsSL \
        "https://github.com/steipete/gogcli/releases/download/v${GOGCLI_VERSION}/gogcli_${GOGCLI_VERSION}_linux_${TARGETARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin/ gogcli \
    && chmod +x /usr/local/bin/gogcli \
    && gogcli --version

# ── 切回原镜像默认非 root 用户 ───────────────────────────────────────────────
# 验证原镜像实际用户：docker inspect ghcr.io/openclaw/openclaw:2026.3.31-slim --format '{{.Config.User}}'
# 若结果不是 node，将下方改为对应用户名或 UID
USER node
