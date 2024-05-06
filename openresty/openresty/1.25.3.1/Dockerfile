FROM cr.loongnix.cn/library/debian:buster-slim AS builder
ARG TARGETARCH

ARG BUILD_DEPENDENCIES="\
        build-essential \
        gettext-base \
        libgd-dev \
        libgeoip-dev \
        libncurses5-dev \
        libperl-dev \
        libreadline-dev \
        libsqlite3-dev \
        libxslt1-dev \
        make \
        perl \
        zlib1g-dev"

ARG TOOLS="\
        ca-certificates \
        curl \
        git \
        unzip \
        wget"

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends $BUILD_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $TOOLS

ARG BUILD_DIR=/tmp/openresty
ARG PREFIX_DIR=/usr/local/openresty

ARG RESTY_VERSION="1.25.3.1"
ARG RESTY_LUAROCKS_VERSION="3.11.0"
ARG RESTY_OPENSSL_VERSION="1.1.1w"
ARG RESTY_OPENSSL_PATCH_VERSION="1.1.1f"
ARG RESTY_OPENSSL_URL_BASE="https://www.openssl.org/source/old/1.1.1"
ARG RESTY_PCRE_VERSION="8.45"

ARG OPENSSL_OPTS="\
    no-threads shared zlib -g \
    enable-ssl3 enable-ssl3-method \
    --prefix=${PREFIX_DIR}/openssl \
    --libdir=lib \
    -Wl,-rpath,${PREFIX_DIR}/openssl/lib"

ARG PCRE_OPTS="\
    --prefix=${PREFIX_DIR}/pcre \
    --disable-cpp \
    --enable-utf \
    --enable-unicode-properties"

ARG OPENRESTY_OPTS="\
    --with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I${PREFIX_DIR}/pcre/include -I${PREFIX_DIR}/openssl/include' \
    --with-ld-opt='-L${PREFIX_DIR}/pcre/lib -L${PREFIX_DIR}/openssl/lib -Wl,-rpath,${PREFIX_DIR}/pcre/lib:${PREFIX_DIR}/openssl/lib' \
    --with-compat \
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    --with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'"

ARG LUAROCKS_OPTS="\
    --prefix=${PREFIX_DIR}/luajit \
    --with-lua=${PREFIX_DIR}/luajit \
    --with-lua-include=${PREFIX_DIR}/luajit/include/luajit-2.1"

ADD build-all.sh list-dependencies.sh ${BUILD_DIR}/

RUN ${BUILD_DIR}/build-all.sh

RUN ${BUILD_DIR}/list-dependencies.sh \
        ${PREFIX_DIR}/bin/openresty \
        > ${PREFIX_DIR}/DEPENDENCIES

FROM cr.loongnix.cn/library/debian:buster-slim

ARG PREFIX_DIR=/usr/local/openresty

ARG RUNTIME_DEPENDENCIES="\
        ca-certificates"

COPY --from=builder ${PREFIX_DIR} ${PREFIX_DIR}

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends $RUNTIME_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc

RUN set -ex \
    && mkdir -p /var/run/openresty \
    && ln -sf /dev/stdout ${PREFIX_DIR}/nginx/logs/access.log \
    && ln -sf /dev/stderr ${PREFIX_DIR}/nginx/logs/error.log

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:${PREFIX_DIR}/luajit/bin:${PREFIX_DIR}/nginx/sbin:${PREFIX_DIR}/bin

# Add LuaRocks paths
# If OpenResty changes, these may need updating:
#    ${PREFIX_DIR}/bin/resty -e 'print(package.path)'
#    ${PREFIX_DIR}/bin/resty -e 'print(package.cpath)'
ENV LUA_PATH="${PREFIX_DIR}/site/lualib/?.ljbc;${PREFIX_DIR}/site/lualib/?/init.ljbc;${PREFIX_DIR}/lualib/?.ljbc;${PREFIX_DIR}/lualib/?/init.ljbc;${PREFIX_DIR}/site/lualib/?.lua;${PREFIX_DIR}/site/lualib/?/init.lua;${PREFIX_DIR}/lualib/?.lua;${PREFIX_DIR}/lualib/?/init.lua;./?.lua;${PREFIX_DIR}/luajit/share/luajit-2.1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;${PREFIX_DIR}/luajit/share/lua/5.1/?.lua;${PREFIX_DIR}/luajit/share/lua/5.1/?/init.lua"

ENV LUA_CPATH="${PREFIX_DIR}/site/lualib/?.so;${PREFIX_DIR}/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;${PREFIX_DIR}/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;${PREFIX_DIR}/luajit/lib/lua/5.1/?.so"

# Copy nginx configuration files
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT