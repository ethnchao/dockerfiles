#!/bin/sh
# 通用镜像初始化主脚本
# 按需通过环境变量控制各步骤，默认全部执行
#
# 可用环境变量（值为 true/false）：
#   SKIP_MIRROR_APT=true    跳过 apt 源配置
#   SKIP_MIRROR_YUM=true    跳过 yum 源配置
#   SKIP_MIRROR_APK=true    跳过 apk 源配置
#   SKIP_MIRROR_NPM=true    跳过 npm/yarn/pnpm 源配置（默认跳过，仅 Node 镜像需要）
#   SKIP_TIMEZONE=true      跳过时区配置
#   SKIP_TOOLS=true         跳过工具安装
#   SKIP_VIM=true           跳过 vim 配置

set -e

# bind mount 挂载后，脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() {
    echo "==> [common-setup] $*"
}

run_script() {
    SCRIPT="$SCRIPT_DIR/$1"
    if [ -f "$SCRIPT" ]; then
        log "运行 $1"
        sh "$SCRIPT"
    else
        log "警告：$1 不存在，跳过"
    fi
}

# ── 镜像源配置 ───────────────────────────────────────────────────────────────

if [ "${SKIP_MIRROR_APT}" != "true" ]; then
    run_script setup-apt-mirror.sh
fi

if [ "${SKIP_MIRROR_YUM}" != "true" ]; then
    run_script setup-yum-mirror.sh
fi

if [ "${SKIP_MIRROR_APK}" != "true" ]; then
    run_script setup-apk-mirror.sh
fi

if [ "${SKIP_MIRROR_NPM}" != "true" ]; then
    run_script setup-npm-mirror.sh
fi

# ── 系统时区 ─────────────────────────────────────────────────────────────────

if [ "${SKIP_TIMEZONE}" != "true" ]; then
    run_script setup-timezone.sh
fi

# ── 常用工具 ─────────────────────────────────────────────────────────────────

if [ "${SKIP_TOOLS}" != "true" ]; then
    run_script install-tools.sh
fi

# ── vim 配置 ─────────────────────────────────────────────────────────────────

if [ "${SKIP_VIM}" != "true" ]; then
    run_script setup-vim.sh
fi

log "通用初始化完成"
