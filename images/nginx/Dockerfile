# syntax=docker/dockerfile:1
# Nginx Alpine 封装镜像
# 基础镜像：nginx:alpine
# 用途：生产级 Nginx，已配置阿里云 apk 源、Asia/Shanghai 时区、内置 vim 等调试工具

FROM nginx:alpine

RUN --mount=type=bind,source=common,target=/tmp/common \
    # apk 源、时区、vim 工具；nginx 镜像不需要 npm 源
    SKIP_MIRROR_APT=true \
    SKIP_MIRROR_YUM=true \
    SKIP_MIRROR_NPM=true \
    sh /tmp/common/common-setup.sh

# 自定义 nginx 配置（按需取消注释）
# COPY nginx.conf /etc/nginx/nginx.conf
# COPY conf.d/    /etc/nginx/conf.d/

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
