FROM cr.loongnix.cn/library/debian:buster-slim as builder
WORKDIR /opt
ARG GUACD_VERSION=1.5.3
ENV LC_ALL=C.UTF-8

ARG PREFIX_DIR=/opt/guacamole

ARG BUILD_DIR=/tmp/guacamole-server

ARG WITH_FREERDP='NO'
ARG WITH_LIBSSH2='NO'
ARG WITH_LIBTELNET='NO'
ARG WITH_LIBVNCCLIENT='NO'
ARG WITH_LIBWEBSOCKETS='NO'

ARG GUACAMOLE_SERVER_OPTS="\
    --disable-guaclog \
    --disable-guacd"

ARG BUILD_DEPENDENCIES="          \
        autoconf                  \
        automake                  \
        build-essential           \
        cmake                     \
        gcc                       \
        git                       \
        g++                       \
        libavcodec-dev            \
        libavformat-dev           \
        libavutil-dev             \
        libcairo2-dev             \
        libjpeg62-turbo-dev       \
        libssl-dev                \
        libswscale-dev            \
        libtool                   \
        libwebp-dev               \
        make"

ARG TOOLS="                       \
        ca-certificates           \
        curl                      \
        git                       \
        wget"

ARG DEBIAN_FRONTEND=noninteractive
RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends $BUILD_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $TOOLS \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@/usr/bin/@/bin/@g" /usr/bin/libtoolize \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && git clone -b ${GUACD_VERSION} https://github.com/apache/guacamole-server ${BUILD_DIR} --depth=1 \
    && wget -O ${BUILD_DIR}/src/guacd-docker/bin/link-freerdp-plugins.sh https://github.com/apache/guacamole-server/raw/c880f02fe88f83ccabbbb5d057a64d4de3dc4219/src/guacd-docker/bin/link-freerdp-plugins.sh \
    && wget -O ${BUILD_DIR}/src/guacd-docker/bin/list-dependencies.sh https://github.com/apache/guacamole-server/raw/c880f02fe88f83ccabbbb5d057a64d4de3dc4219/src/guacd-docker/bin/list-dependencies.sh \
    && chmod 755 ${BUILD_DIR}/src/guacd-docker/bin/*.sh

RUN ${BUILD_DIR}/src/guacd-docker/bin/build-all.sh

RUN ${BUILD_DIR}/src/guacd-docker/bin/list-dependencies.sh \
        ${PREFIX_DIR}/bin/guacenc                         \
        > ${PREFIX_DIR}/DEPENDENCIES

FROM cr.loongnix.cn/library/debian:buster-slim

ARG PREFIX_DIR=/opt/guacamole

ENV LANG="en_US.UTF-8"
ENV LD_LIBRARY_PATH=${PREFIX_DIR}/lib

ARG RUNTIME_DEPENDENCIES="            \
        ca-certificates               \
        ffmpeg                        \
        fonts-dejavu                  \
        fonts-liberation              \
        ghostscript                   \
        netcat-openbsd                \
        xfonts-terminus"

ARG DEBIAN_FRONTEND=noninteractive
COPY --from=builder ${PREFIX_DIR} ${PREFIX_DIR}

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends $RUNTIME_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && echo "no" | dpkg-reconfigure dash \
    && rm -rf /var/lib/apt/lists/*
