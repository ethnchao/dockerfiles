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
  # 目标构建平台，多平台用逗号分隔
  default = "linux/amd64,linux/arm64"
}

# ── 构建目标分组 ──────────────────────────────────────────────────────────────

group "default" {
  targets = ["ubuntu", "nginx", "node"]
}

# ── 通用继承基础（私有，以 _ 开头） ──────────────────────────────────────────

target "_common" {
  # 构建上下文为仓库根目录，保证 common/ 目录对所有 Dockerfile 可见
  context   = "."
  platforms = [BUILD_PLATFORMS]
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
