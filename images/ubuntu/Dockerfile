# syntax=docker/dockerfile:1
# Ubuntu 22.04 通用封装镜像
# 基础镜像：ubuntu:22.04
# 用途：作为其他 Ubuntu 系镜像的通用基础层，已内置国内源、时区、常用工具

FROM ubuntu:22.04

# bind mount 整个 common 目录，脚本执行完毕后不进入镜像层
RUN --mount=type=bind,source=common,target=/tmp/common \
    sh /tmp/common/common-setup.sh

CMD ["/bin/bash"]
