# syntax=docker/dockerfile:1
# Node.js LTS 封装镜像
# 基础镜像：node:20-bullseye-slim
# 用途：Node.js 开发/生产镜像，已配置阿里云 apt 源、npmmirror、Asia/Shanghai 时区

FROM node:20-bullseye-slim

RUN --mount=type=bind,source=common,target=/tmp/common \
    # apt 源 + npm 源 + 时区 + 工具；不需要 yum/apk 源
    SKIP_MIRROR_YUM=true \
    SKIP_MIRROR_APK=true \
    sh /tmp/common/common-setup.sh

WORKDIR /app

CMD ["node"]
