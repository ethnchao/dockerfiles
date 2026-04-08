#!/bin/sh
# 将 Debian/Ubuntu apt 源替换为阿里云镜像
# 支持：Ubuntu 20.04 / 22.04 / 24.04、Debian 11 / 12

set -e

if [ ! -f /etc/os-release ]; then
    echo "[setup-apt-mirror] 非 Debian/Ubuntu 系统，跳过"
    exit 0
fi

. /etc/os-release

case "$ID" in
    ubuntu)
        MIRROR="https://mirrors.aliyun.com/ubuntu"
        cat > /etc/apt/sources.list <<EOF
deb ${MIRROR}/ ${VERSION_CODENAME} main restricted universe multiverse
deb ${MIRROR}/ ${VERSION_CODENAME}-security main restricted universe multiverse
deb ${MIRROR}/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb ${MIRROR}/ ${VERSION_CODENAME}-backports main restricted universe multiverse
EOF
        # Ubuntu 24.04+ 使用 sources.list.d 的 deb822 格式，需要禁用原有配置
        if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
            rm -f /etc/apt/sources.list.d/ubuntu.sources
        fi
        echo "[setup-apt-mirror] Ubuntu ${VERSION_CODENAME} apt 源已切换为阿里云"
        ;;
    debian)
        MIRROR="https://mirrors.aliyun.com/debian"
        cat > /etc/apt/sources.list <<EOF
deb ${MIRROR}/ ${VERSION_CODENAME} main contrib non-free non-free-firmware
deb ${MIRROR}/ ${VERSION_CODENAME}-updates main contrib non-free non-free-firmware
deb https://mirrors.aliyun.com/debian-security/ ${VERSION_CODENAME}-security main contrib non-free non-free-firmware
EOF
        echo "[setup-apt-mirror] Debian ${VERSION_CODENAME} apt 源已切换为阿里云"
        ;;
    *)
        echo "[setup-apt-mirror] 不支持的发行版：$ID，跳过"
        exit 0
        ;;
esac

apt-get update -qq
