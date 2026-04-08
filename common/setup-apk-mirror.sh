#!/bin/sh
# 将 Alpine Linux apk 源替换为阿里云镜像

set -e

if [ ! -f /etc/alpine-release ]; then
    echo "[setup-apk-mirror] 非 Alpine 系统，跳过"
    exit 0
fi

ALPINE_VERSION=$(cat /etc/alpine-release | cut -d. -f1-2)
MIRROR="https://mirrors.aliyun.com/alpine/v${ALPINE_VERSION}"

cat > /etc/apk/repositories <<EOF
${MIRROR}/main
${MIRROR}/community
EOF

apk update -q
echo "[setup-apk-mirror] Alpine v${ALPINE_VERSION} apk 源已切换为阿里云"
