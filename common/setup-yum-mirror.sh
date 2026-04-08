#!/bin/sh
# 将 CentOS/RHEL/Rocky/AlmaLinux yum/dnf 源替换为阿里云镜像
# 支持：CentOS 7/8、Rocky Linux 8/9、AlmaLinux 8/9

set -e

if [ ! -f /etc/os-release ]; then
    echo "[setup-yum-mirror] 非 RPM 系系统，跳过"
    exit 0
fi

. /etc/os-release

# 检查是否为 RPM 系
if ! command -v rpm > /dev/null 2>&1; then
    echo "[setup-yum-mirror] 未发现 rpm 命令，跳过"
    exit 0
fi

# 判断包管理器
if command -v dnf > /dev/null 2>&1; then
    PKG_MGR=dnf
elif command -v yum > /dev/null 2>&1; then
    PKG_MGR=yum
else
    echo "[setup-yum-mirror] 未找到 yum/dnf，跳过"
    exit 0
fi

MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)

case "$ID" in
    centos)
        if [ "$MAJOR_VERSION" = "7" ]; then
            curl -fsSL -o /etc/yum.repos.d/CentOS-Base.repo \
                https://mirrors.aliyun.com/repo/Centos-7.repo
        else
            curl -fsSL -o /etc/yum.repos.d/CentOS-Base.repo \
                https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
        fi
        ;;
    rocky | almalinux | rhel)
        # 使用 sed 替换 mirrorlist 为 baseurl 指向阿里云
        sed -i \
            -e 's|^mirrorlist=|#mirrorlist=|g' \
            -e "s|^#baseurl=http://dl.rockylinux.org/\$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g" \
            /etc/yum.repos.d/Rocky-*.repo 2>/dev/null || true
        sed -i \
            -e 's|^mirrorlist=|#mirrorlist=|g' \
            -e "s|^#baseurl=https://repo.almalinux.org|baseurl=https://mirrors.aliyun.com/almalinux|g" \
            /etc/yum.repos.d/almalinux*.repo 2>/dev/null || true
        ;;
    *)
        echo "[setup-yum-mirror] 不支持的发行版：$ID，跳过"
        exit 0
        ;;
esac

$PKG_MGR makecache -q
echo "[setup-yum-mirror] ${ID} ${VERSION_ID} yum 源已切换为阿里云"
