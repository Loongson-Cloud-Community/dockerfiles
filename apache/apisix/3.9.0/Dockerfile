FROM cr.loongnix.cn/apache/apisix-runtime-deb:1.3.3 AS build

ARG APISIX_VERSION=3.9.0

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
    && apt-get -y update --fix-missing \
    && apt-get install -y --no-install-recommends \
        curl \
        gawk \
        git \
        libldap2-dev \
        liblua5.1-0-dev \
        lua5.1 \
        make \
        gcc \
        unzip \
        wget \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

#RUN curl https://raw.githubusercontent.com/apache/apisix/master/utils/linux-install-luarocks.sh -sL | bash -
RUN curl -sL https://raw.githubusercontent.com/apache/apisix/master/utils/linux-install-luarocks.sh -o /tmp/install-luarocks.sh \
    && sed -i 's/sudo //g' /tmp/install-luarocks.sh \
    && chmod +x /tmp/install-luarocks.sh \
    && /tmp/install-luarocks.sh \
    && rm -f /tmp/install-luarocks.sh \
    && ln -sf /usr/local/bin/luarocks /usr/local/openresty/luajit/bin/luarocks

RUN luarocks install \
    https://raw.githubusercontent.com/lualdap/lualdap/master/rockspec/lualdap-1.2.6-1.rockspec \
    LDAP_INCDIR=/usr/include \
    LDAP_LIBDIR=/usr/lib/loongarch64-linux-gnu \
    --tree=/usr/local/apisix/deps \
    --lua-version=5.1

RUN wget https://raw.githubusercontent.com/apache/apisix/3.9.0/apisix-master-0.rockspec -O apisix-master-0.rockspec \
    && sed -i 's/branch = "master"/branch = "3.9.0"/' apisix-master-0.rockspec \
    && luarocks install apisix-master-0.rockspec \
    --tree=/usr/local/apisix/deps \ 
    PCRE_DIR=/usr/local/openresty/pcre \
    && cp -v /usr/local/apisix/deps/lib/luarocks/rocks-5.1/apisix/master-0/bin/apisix /usr/bin/ \
    && mv /usr/local/apisix/deps/share/lua/5.1/apisix /usr/local/apisix \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /usr/local/apisix/logs/access.log \
    && ln -sf /dev/stderr /usr/local/apisix/logs/error.log


FROM cr.loongnix.cn/apache/apisix-runtime-deb:1.3.3 AS production-stage

COPY --from=build /usr/local/apisix /usr/local/apisix
COPY --from=build /usr/bin/apisix /usr/bin/apisix


RUN sed -i 's/require("ngx.re").opt("jit_stack_size"/-- &/' /usr/local/apisix/apisix/init.lua

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update --fix-missing \
    && apt-get install -y \
        libldap2-dev \
        libyaml-0-2 \
        wget \
    && rm -rf /var/lib/apt/lists/*


# install-brotli.sh 需要cmake >= 3.15
RUN wget -O /tmp/cmake-3.31.2.tar.gz https://cloud.loongnix.cn/releases/loongarch64abi1/Kitware/CMake/3.31.2/cmake-3.31.2-Linux-loongarch64.tar.gz && \
    tar -xzf /tmp/cmake-3.31.2.tar.gz -C /tmp && \
    mkdir -p /usr/local/cmake && \
    mv /tmp/cmake-3.31.2-Linux-loongarch64/* /usr/local/cmake && \
    rm -rf /tmp/cmake-3.31.2.tar.gz /tmp/cmake-3.31.2-Linux-loongarch64

COPY ./install-brotli.sh /install-brotli.sh
RUN chmod +x /install-brotli.sh \  
    && cd / && ./install-brotli.sh && rm -rf /install-brotli.sh \
    && rm -rf /usr/local/cmake
    
WORKDIR /usr/local/apisix

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

EXPOSE 9080 9443

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["docker-start"]

STOPSIGNAL SIGQUIT
