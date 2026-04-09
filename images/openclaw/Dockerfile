# syntax=docker/dockerfile:1
# OpenClaw 封装镜像
# 基础镜像：ghcr.io/openclaw/openclaw:2026.3.31-slim
# 用途：OpenClaw 应用镜像，已配置阿里云 apt 源、Asia/Shanghai 时区、内置常用调试工具

FROM ghcr.io/openclaw/openclaw:2026.3.31-slim

RUN --mount=type=bind,source=common,target=/tmp/common \
    # slim 镜像基于 Debian，跳过 yum / apk / npm 源配置
    SKIP_MIRROR_YUM=true \
    SKIP_MIRROR_APK=true \
    SKIP_MIRROR_NPM=true \
    sh /tmp/common/common-setup.sh
