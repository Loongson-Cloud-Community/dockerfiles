FROM cr.loongnix.cn/library/debian:buster-slim as builder
WORKDIR /opt
ARG GUACD_VERSION=1.5.4
ENV LC_ALL=C.UTF-8

ARG BUILD_DIR=/tmp/guacamole-server

#
# Base directory for installed build artifacts.
#
# NOTE: Due to limitations of the Docker image build process, this value is
# duplicated in an ARG in the second stage of the build.
#
ARG PREFIX_DIR=/opt/guacamole

#
# Automatically select the latest versions of each core protocol support
# library (these can be overridden at build time if a specific version is
# needed)
#
ARG WITH_FREERDP='2(\.\d+)+'
ARG WITH_LIBSSH2='libssh2-\d+(\.\d+)+'
ARG WITH_LIBTELNET='\d+(\.\d+)+'
ARG WITH_LIBVNCCLIENT='LibVNCServer-\d+(\.\d+)+'
ARG WITH_LIBWEBSOCKETS='v\d+(\.\d+)+'

#
# Default build options for each core protocol support library, as well as
# guacamole-server itself (these can be overridden at build time if different
# options are needed)
#

ARG FREERDP_OPTS="\
    -DBUILTIN_CHANNELS=OFF \
    -DCHANNEL_URBDRC=OFF \
    -DWITH_ALSA=OFF \
    -DWITH_CAIRO=ON \
    -DWITH_CHANNELS=ON \
    -DWITH_CLIENT=ON \
    -DWITH_CUPS=OFF \
    -DWITH_DIRECTFB=OFF \
    -DWITH_FFMPEG=OFF \
    -DWITH_GSM=OFF \
    -DWITH_GSSAPI=OFF \
    -DWITH_IPP=OFF \
    -DWITH_JPEG=ON \
    -DWITH_LIBSYSTEMD=OFF \
    -DWITH_MANPAGES=OFF \
    -DWITH_OPENH264=OFF \
    -DWITH_OPENSSL=ON \
    -DWITH_OSS=OFF \
    -DWITH_PCSC=OFF \
    -DWITH_PULSE=OFF \
    -DWITH_SERVER=OFF \
    -DWITH_SERVER_INTERFACE=OFF \
    -DWITH_SHADOW_MAC=OFF \
    -DWITH_SHADOW_X11=OFF \
    -DWITH_SSE2=OFF \
    -DWITH_WAYLAND=OFF \
    -DWITH_X11=OFF \
    -DWITH_X264=OFF \
    -DWITH_XCURSOR=ON \
    -DWITH_XEXT=ON \
    -DWITH_XI=OFF \
    -DWITH_XINERAMA=OFF \
    -DWITH_XKBFILE=ON \
    -DWITH_XRENDER=OFF \
    -DWITH_XTEST=OFF \
    -DWITH_XV=OFF \
    -DWITH_ZLIB=ON"

ARG GUACAMOLE_SERVER_OPTS="\
    --disable-guaclog"

ARG LIBSSH2_OPTS="\
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_SHARED_LIBS=ON"

ARG LIBTELNET_OPTS="\
    --disable-static \
    --disable-util"

ARG LIBVNCCLIENT_OPTS=""

ARG LIBWEBSOCKETS_OPTS="\
    -DDISABLE_WERROR=ON \
    -DLWS_WITHOUT_SERVER=ON \
    -DLWS_WITHOUT_TESTAPPS=ON \
    -DLWS_WITHOUT_TEST_CLIENT=ON \
    -DLWS_WITHOUT_TEST_PING=ON \
    -DLWS_WITHOUT_TEST_SERVER=ON \
    -DLWS_WITHOUT_TEST_SERVER_EXTPOLL=ON \
    -DLWS_WITH_STATIC=OFF"

ARG BUILD_DEPENDENCIES="          \
        autoconf                  \
        automake                  \
        build-essential           \
        cmake                     \
        gcc                       \
        git                       \
        g++                       \
        libcairo2-dev             \
        libjpeg62-turbo-dev       \
        libssl-dev                \
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
    && git clone -b ${GUACD_VERSION} --depth=1 https://github.com/apache/guacamole-server ${BUILD_DIR} \
    && wget -O ${BUILD_DIR}/src/guacd-docker/bin/link-freerdp-plugins.sh https://github.com/apache/guacamole-server/raw/c880f02fe88f83ccabbbb5d057a64d4de3dc4219/src/guacd-docker/bin/link-freerdp-plugins.sh \
    && wget -O ${BUILD_DIR}/src/guacd-docker/bin/list-dependencies.sh https://github.com/apache/guacamole-server/raw/c880f02fe88f83ccabbbb5d057a64d4de3dc4219/src/guacd-docker/bin/list-dependencies.sh \
    && chmod 755 ${BUILD_DIR}/src/guacd-docker/bin/*.sh

# Build guacamole-server and its core protocol library dependencies
RUN ${BUILD_DIR}/src/guacd-docker/bin/build-all.sh

# Record the packages of all runtime library dependencies
RUN ${BUILD_DIR}/src/guacd-docker/bin/list-dependencies.sh \
        ${PREFIX_DIR}/sbin/guacd               \
        ${PREFIX_DIR}/lib/libguac-client-*.so  \
        ${PREFIX_DIR}/lib/freerdp2/*guac*.so   \
        > ${PREFIX_DIR}/DEPENDENCIES

FROM cr.loongnix.cn/library/debian:buster-slim
#
# Base directory for installed build artifacts. See also the
# CMD directive at the end of this build stage.
#
# NOTE: Due to limitations of the Docker image build process, this value is
# duplicated in an ARG in the first stage of the build.
#
ARG PREFIX_DIR=/opt/guacamole

# Runtime environment
ENV LANG="en_US.UTF-8"
ENV LD_LIBRARY_PATH=${PREFIX_DIR}/lib
ENV GUACD_LOG_LEVEL=info

# Copy build artifacts into this stage
COPY --from=builder ${PREFIX_DIR} ${PREFIX_DIR}

# Bring runtime environment up to date and install runtime dependencies
ARG RUNTIME_DEPENDENCIES="            \
        ca-certificates               \
        fonts-dejavu                  \
        fonts-liberation              \
        ghostscript                   \
        netcat-openbsd                \
        xfonts-terminus"

ARG DEBIAN_FRONTEND=noninteractive
RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends $RUNTIME_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && echo "no" | dpkg-reconfigure dash \
    && rm -rf /var/lib/apt/lists/*

# Checks the operating status every 5 minutes with a timeout of 5 seconds
HEALTHCHECK --interval=5m --timeout=5s CMD nc -z 127.0.0.1 4822 || exit 1

# Create a new user guacd
ARG UID=1000
ARG GID=1000
RUN groupadd --gid $GID guacd
RUN useradd --system --create-home --shell /usr/sbin/nologin --uid $UID --gid $GID guacd

# Run with user guacd
USER guacd

# Expose the default listener port
EXPOSE 4822

# Start guacd, listening on port 0.0.0.0:4822
#
# Note the path here MUST correspond to the value specified in the
# PREFIX_DIR build argument.
#
CMD /opt/guacamole/sbin/guacd -b 0.0.0.0 -L $GUACD_LOG_LEVEL -f