#!/bin/sh
# 将 npm / yarn / pnpm 源配置为 npmmirror 国内镜像

set -e

NPM_REGISTRY="https://registry.npmmirror.com"

if command -v npm > /dev/null 2>&1; then
    npm config set registry "$NPM_REGISTRY"
    echo "[setup-npm-mirror] npm 源已设置为 ${NPM_REGISTRY}"
else
    echo "[setup-npm-mirror] 未发现 npm，跳过"
fi

if command -v yarn > /dev/null 2>&1; then
    yarn config set registry "$NPM_REGISTRY" --global 2>/dev/null || true
    echo "[setup-npm-mirror] yarn 源已设置为 ${NPM_REGISTRY}"
fi

if command -v pnpm > /dev/null 2>&1; then
    pnpm config set registry "$NPM_REGISTRY" --global 2>/dev/null || true
    echo "[setup-npm-mirror] pnpm 源已设置为 ${NPM_REGISTRY}"
fi

# 将配置写入全局 .npmrc，确保对所有用户生效
cat > /etc/npmrc <<EOF
registry=${NPM_REGISTRY}
EOF

# Node.js 镜像下载加速
echo "node_mirror=https://npmmirror.com/mirrors/node/" >> /etc/npmrc
echo "npm_mirror=https://npmmirror.com/mirrors/npm/"  >> /etc/npmrc
