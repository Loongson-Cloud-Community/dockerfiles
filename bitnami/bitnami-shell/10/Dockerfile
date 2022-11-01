FROM cr.loongnix.cn/bitnami/minideb:buster-loong64
LABEL maintainer="wangweijie@loongson.cn"

COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages curl procps
RUN apt-get update && apt-get upgrade -y && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives

ENV APP_VERSION="10" \
    BITNAMI_APP_NAME="bitnami-shell" \
    OS_ARCH="loongarch64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

