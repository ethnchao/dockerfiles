#!/bin/sh
# 安装常用运维工具：vim、ping、nslookup、netstat
# 自动根据系统类型选择 apt / yum / apk

set -e

install_apt() {
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y --no-install-recommends \
        vim \
        iputils-ping \
        dnsutils \
        net-tools \
        curl \
        wget \
        procps
    rm -rf /var/lib/apt/lists/*
    echo "[install-tools] Debian/Ubuntu 工具安装完成"
}

install_yum() {
    if command -v dnf > /dev/null 2>&1; then
        PKG_MGR=dnf
    else
        PKG_MGR=yum
    fi
    $PKG_MGR install -y \
        vim \
        iputils \
        bind-utils \
        net-tools \
        curl \
        wget \
        procps-ng
    $PKG_MGR clean all
    echo "[install-tools] CentOS/RHEL 工具安装完成"
}

install_apk() {
    apk add --no-cache \
        vim \
        iputils \
        bind-tools \
        net-tools \
        curl \
        wget \
        procps
    echo "[install-tools] Alpine 工具安装完成"
}

if [ -f /etc/alpine-release ]; then
    install_apk
elif command -v apt-get > /dev/null 2>&1; then
    install_apt
elif command -v yum > /dev/null 2>&1 || command -v dnf > /dev/null 2>&1; then
    install_yum
else
    echo "[install-tools] 未识别的包管理器，跳过工具安装"
    exit 0
fi
