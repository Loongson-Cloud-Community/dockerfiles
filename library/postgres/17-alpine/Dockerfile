FROM cr.loongnix.cn/library/alpine:3.11

# 1. 更新软件索引 + 基础证书
RUN set -eux; \
    apk update; \
    apk add --no-cache ca-certificates

# 2. 创建 postgres 用户/组（UID/GID 70，与官方镜像一致）
RUN set -eux; \
    addgroup -g 70 -S postgres; \
    adduser -u 70 -S -D -G postgres -H -h /var/lib/postgresql -s /bin/sh postgres; \
    install -d -o postgres -g postgres -m 1777 /var/lib/postgresql

# 3. 用 su-exec 替代 gosu（Alpine 原生 musl 包，用法与 gosu 兼容）
#    龙芯社区发布的 gosu-loong64-abi1.0 是 glibc 动态二进制，在 musl 上无法运行。
#    这里创建一个名为 gosu 的包装脚本，内部 exec su-exec "$@"，
#    使官方 docker-entrypoint.sh 中的 "gosu postgres ..." 调用无需任何修改。
RUN set -eux; \
    apk add --no-cache su-exec; \
    printf '#!/bin/sh\nexec su-exec "$@"\n' > /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/gosu; \
    gosu postgres id; \
    gosu postgres true

# 4. 初始化脚本目录 + 示例配置调整
ENV LANG en_US.utf8
RUN mkdir /docker-entrypoint-initdb.d

ENV PG_MAJOR 17
ENV PG_VERSION 17.11
ENV PG_SHA256 dd27f2b3c59e73ed14aa3324901242bf69a032a6347805f274e6260322d42979

# 5. 下载源码
WORKDIR /usr/src/postgresql
RUN set -eux; \
    wget -O postgresql.tar.bz2 "https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2"; \
    echo "${PG_SHA256} *postgresql.tar.bz2" | sha256sum -c -; \
    tar -xjf postgresql.tar.bz2 -C /usr/src/postgresql --strip-components=1; \
    rm postgresql.tar.bz2

# 可选：应用 LoongArch 补丁
# COPY add-loongarch-support.patch /tmp/
# RUN cd /usr/src/postgresql && patch -p1 < /tmp/add-loongarch-support.patch

# 6. 构建依赖 + 编译安装
RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
        bison \
        coreutils \
        dpkg-dev dpkg \
        flex \
        g++ \
        gcc \
        krb5-dev \
        libc-dev \
        libedit-dev \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        make \
        openldap-dev \
        openssl-dev \
        pax-utils \
        perl-dev \
        perl-ipc-run \
        perl-utils \
        python3-dev \
        tcl-dev \
        util-linux-dev \
        icu-dev \
        zlib-dev \
    ; \
    cd /usr/src/postgresql; \
# 调整默认 socket 目录
    awk '$1 == "#define" && $2 == "DEFAULT_PGSOCKET_DIR" && $3 == "\"/tmp\"" { $3 = "\"/var/run/postgresql\""; print; next } { print }' src/include/pg_config_manual.h > src/include/pg_config_manual.h.new; \
    grep '/var/run/postgresql' src/include/pg_config_manual.h.new; \
    mv src/include/pg_config_manual.h.new src/include/pg_config_manual.h; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --enable-option-checking=fatal \
        --build="$gnuArch" \
        --enable-integer-datetimes \
        --enable-tap-tests \
        --disable-rpath \
        --with-uuid=e2fs \
        --with-pgport=5432 \
        --with-system-tzdata=/usr/share/zoneinfo \
        --prefix=/usr/local \
        --with-includes=/usr/local/include \
        --with-libraries=/usr/local/lib \
        --with-gssapi \
        --with-icu \
        --with-ldap \
        --with-libxml \
        --with-libxslt \
        --without-llvm \
        --with-openssl \
        --with-perl \
        --with-python \
        --with-tcl \
    ; \
    make -j "$(nproc)" world-bin; \
    make install-world-bin; \
    make -C contrib install; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
            | grep -v -e perl -e python -e tcl \
    )"; \
    apk add --no-cache --virtual .postgresql-rundeps \
        $runDeps \
        bash \
        tzdata \
        icu \
    ; \
    apk del --no-network .build-deps; \
    cd /; \
    rm -rf /usr/src/postgresql /usr/local/share/doc /usr/local/share/man; \
    postgres --version

# 7. 调整示例配置，方便容器默认监听所有地址
RUN set -eux; \
    cp -v /usr/local/share/postgresql/postgresql.conf.sample /usr/local/share/postgresql/postgresql.conf.sample.orig; \
    sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/local/share/postgresql/postgresql.conf.sample; \
    grep -F "listen_addresses = '*'" /usr/local/share/postgresql/postgresql.conf.sample

RUN install -d -o postgres -g postgres -m 3777 /var/run/postgresql

ENV PGDATA /var/lib/postgresql/data
RUN install -d -o postgres -g postgres -m 1777 "$PGDATA"
VOLUME /var/lib/postgresql/data

# 8. 官方入口脚本
COPY docker-entrypoint.sh docker-ensure-initdb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-ensure-initdb.sh; \
    ln -sf docker-ensure-initdb.sh /usr/local/bin/docker-enforce-initdb.sh

# musl 环境下 en_US.utf8 不存在，初始化时强制使用 C locale
ENV POSTGRES_INITDB_ARGS="--locale=C --encoding=UTF8"

ENTRYPOINT ["docker-entrypoint.sh"]
STOPSIGNAL SIGINT
EXPOSE 5432
CMD ["postgres"]
