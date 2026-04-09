#!/bin/sh
# 将 Debian/Ubuntu apt 源替换为阿里云镜像
# 支持：Ubuntu 20.04 / 22.04 / 24.04、Debian 11 / 12
#
# 注意：故意使用 HTTP 而非 HTTPS，原因：
#   slim 基础镜像（如 node:*-slim、python:*-slim）通常不预装 ca-certificates，
#   HTTPS 源会因 SSL 验证失败导致 apt-get update 拉取包列表为空。
#   apt 本身已通过 GPG 签名校验包完整性，HTTP 传输在 Docker 构建场景可接受。

set -e

if [ ! -f /etc/os-release ]; then
    echo "[setup-apt-mirror] 非 Debian/Ubuntu 系统，跳过"
    exit 0
fi

. /etc/os-release

case "$ID" in
    ubuntu)
        # 阿里云 Ubuntu 镜像分两个仓库：
        #   mirrors.aliyun.com/ubuntu       → 仅含 amd64 / i386
        #   mirrors.aliyun.com/ubuntu-ports → arm64 / armhf / riscv64 等 ports 架构
        ARCH=$(dpkg --print-architecture 2>/dev/null || uname -m)
        case "$ARCH" in
            amd64|i386)
                MIRROR="http://mirrors.aliyun.com/ubuntu"
                ;;
            *)
                MIRROR="http://mirrors.aliyun.com/ubuntu-ports"
                ;;
        esac

        cat > /etc/apt/sources.list <<EOF
deb ${MIRROR}/ ${VERSION_CODENAME} main restricted universe multiverse
deb ${MIRROR}/ ${VERSION_CODENAME}-security main restricted universe multiverse
deb ${MIRROR}/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb ${MIRROR}/ ${VERSION_CODENAME}-backports main restricted universe multiverse
EOF
        # Ubuntu 24.04+ 使用 deb822 格式（sources.list.d/ubuntu.sources），需移除避免冲突
        if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
            rm -f /etc/apt/sources.list.d/ubuntu.sources
        fi
        echo "[setup-apt-mirror] Ubuntu ${VERSION_CODENAME} (${ARCH}) apt 源已切换为阿里云 → ${MIRROR}"
        ;;
    debian)
        MIRROR="http://mirrors.aliyun.com/debian"
        SECURITY_MIRROR="http://mirrors.aliyun.com/debian-security"

        # non-free-firmware 组件仅 Debian 12 (bookworm) 及以上存在
        # Debian 11 (bullseye) 写入该组件会导致 apt-get update 报 404 警告
        MAJOR_VER=$(echo "${VERSION_ID}" | cut -d. -f1)
        if [ "${MAJOR_VER}" -ge 12 ] 2>/dev/null; then
            COMPONENTS="main contrib non-free non-free-firmware"
        else
            COMPONENTS="main contrib non-free"
        fi

        cat > /etc/apt/sources.list <<EOF
deb ${MIRROR}/ ${VERSION_CODENAME} ${COMPONENTS}
deb ${MIRROR}/ ${VERSION_CODENAME}-updates ${COMPONENTS}
deb ${SECURITY_MIRROR}/ ${VERSION_CODENAME}-security ${COMPONENTS}
EOF
        echo "[setup-apt-mirror] Debian ${VERSION_CODENAME} apt 源已切换为阿里云（组件：${COMPONENTS}）"
        ;;
    *)
        echo "[setup-apt-mirror] 不支持的发行版：$ID，跳过"
        exit 0
        ;;
esac

apt-get update -qq
