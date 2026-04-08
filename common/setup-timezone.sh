#!/bin/sh
# 设置系统时区为 Asia/Shanghai（通过写入 /etc/localtime，非环境变量方式）

set -e

TZ_TARGET="Asia/Shanghai"
TZ_FILE="/usr/share/zoneinfo/${TZ_TARGET}"

setup_timezone_apt() {
    # 防止 tzdata 安装时出现交互提示
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y --no-install-recommends tzdata
    ln -sf "$TZ_FILE" /etc/localtime
    echo "$TZ_TARGET" > /etc/timezone
    echo "[setup-timezone] Debian/Ubuntu 时区已设置为 ${TZ_TARGET}"
}

setup_timezone_yum() {
    yum install -y tzdata 2>/dev/null || dnf install -y tzdata
    ln -sf "$TZ_FILE" /etc/localtime
    echo "[setup-timezone] CentOS/RHEL 时区已设置为 ${TZ_TARGET}"
}

setup_timezone_apk() {
    # Alpine 中 tzdata 安装后可以删除，cp 一份保留时区文件
    apk add --no-cache tzdata
    cp "$TZ_FILE" /etc/localtime
    echo "$TZ_TARGET" > /etc/timezone
    apk del tzdata
    echo "[setup-timezone] Alpine 时区已设置为 ${TZ_TARGET}"
}

if [ -f /etc/alpine-release ]; then
    setup_timezone_apk
elif command -v apt-get > /dev/null 2>&1; then
    setup_timezone_apt
elif command -v yum > /dev/null 2>&1 || command -v dnf > /dev/null 2>&1; then
    setup_timezone_yum
else
    # 尝试直接软链（若 tzdata 已内置）
    if [ -f "$TZ_FILE" ]; then
        ln -sf "$TZ_FILE" /etc/localtime
        echo "$TZ_TARGET" > /etc/timezone
        echo "[setup-timezone] 时区已设置为 ${TZ_TARGET}（使用已有 tzdata）"
    else
        echo "[setup-timezone] 无法确定包管理器，且 tzdata 不存在，跳过"
        exit 1
    fi
fi
