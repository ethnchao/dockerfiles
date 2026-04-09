# docker-bake.hcl — 多镜像并行构建配置
# 文档：https://docs.docker.com/build/bake/
#
# 使用方式：
#   docker buildx bake                                    # 构建所有镜像（推送至默认仓库）
#   docker buildx bake --set "*.output=type=docker"       # 仅加载到本地，不推送
#   REGISTRY=harbor.mcdchina.net/devops-public docker buildx bake nginx
#   TAG=20240101 docker buildx bake ubuntu

# ── 变量定义 ─────────────────────────────────────────────────────────────────

variable "REGISTRY" {
  # 覆盖方式：export REGISTRY=harbor.mcdchina.net/devops-public
  # 已知选项：
  #   registry.cn-hangzhou.aliyuncs.com/onemanstudio   （默认，阿里云）
  #   harbor.mcdchina.net/devops-public                （Harbor 私仓）
  default = "registry.cn-hangzhou.aliyuncs.com/onemanstudio"
}

variable "TAG" {
  # 构建版本标签，CI 中建议传入 git short SHA 或日期
  default = "latest"
}

variable "BUILD_PLATFORMS" {
  # 留空 = 使用当前宿主机原生平台（兼容本地默认 docker driver，无需额外 builder）
  # 多平台构建时设置为 "linux/amd64,linux/arm64"（需要 docker-container driver，见下方说明）
  #
  # 本地启用多平台：
  #   docker buildx create --name multiarch --driver docker-container --use --bootstrap
  #   BUILD_PLATFORMS=linux/amd64,linux/arm64 docker buildx bake --push
  #
  # CI（云效）中流水线已自动创建 docker-container driver builder，可直接使用多平台。
  default = ""
}

# ── 构建目标分组 ──────────────────────────────────────────────────────────────

group "default" {
  targets = ["ubuntu", "nginx", "node", "openclaw"]
}

# ── 通用继承基础（私有，以 _ 开头） ──────────────────────────────────────────

target "_common" {
  # 构建上下文为仓库根目录，保证 common/ 目录对所有 Dockerfile 可见
  context = "."
  # BUILD_PLATFORMS 为空时不设置 platforms，bake 自动使用宿主机原生平台
  # BUILD_PLATFORMS 非空时用 split() 正确拆分为平台列表（[VAR] 写法会把整个字符串当一个元素）
  platforms = BUILD_PLATFORMS != "" ? split(",", BUILD_PLATFORMS) : null
}

# ── 各镜像构建目标 ────────────────────────────────────────────────────────────

target "ubuntu" {
  inherits   = ["_common"]
  dockerfile = "images/ubuntu/Dockerfile"
  tags = [
    "${REGISTRY}/ubuntu:${TAG}",
    "${REGISTRY}/ubuntu:22.04",
  ]
}

target "nginx" {
  inherits   = ["_common"]
  dockerfile = "images/nginx/Dockerfile"
  tags = [
    "${REGISTRY}/nginx:${TAG}",
    "${REGISTRY}/nginx:alpine",
  ]
}

target "node" {
  inherits   = ["_common"]
  dockerfile = "images/node/Dockerfile"
  tags = [
    "${REGISTRY}/node:${TAG}",
    "${REGISTRY}/node:20-lts",
  ]
}

target "openclaw" {
  inherits   = ["_common"]
  dockerfile = "images/openclaw/Dockerfile"
  tags = [
    "${REGISTRY}/openclaw:${TAG}",
    "${REGISTRY}/openclaw:2026.3.31-slim",
  ]
}
