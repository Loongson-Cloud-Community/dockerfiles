# 基于龙芯 ABI 1.0 的 Alpine 3.11
FROM cr.loongnix.cn/library/alpine:3.11

# 70 is the standard uid/gid for "postgres" in Alpine
RUN set -eux; \
    addgroup -g 70 -S postgres; \
    adduser -u 70 -S -D -G postgres -H -h /var/lib/postgresql -s /bin/sh postgres; \
    install -d -o postgres -g postgres -m 1777 /var/lib/postgresql

# 获取 loongarch64 ABI 1.0 的 gosu
ENV GOSU_VERSION 1.17
RUN set -eux; \
    apk add --no-cache --virtual .gosu-deps ca-certificates dpkg gnupg; \
    wget -O /usr/local/bin/gosu \
        "https://github.com/Loongson-Cloud-Community/gosu/releases/download/loongarch64-old-abi-1.17/gosu-loongarch64"; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

ENV LANG en_US.utf8
RUN install -d -m 755 /docker-entrypoint-initdb.d

# ── PostgreSQL 17 参数 ──
ENV PG_MAJOR 17
ENV PG_VERSION 17.11
ENV PG_SHA256 dd27f2b3c59e73ed14aa3324901242bf69a032a6347805f274e6260322d42979

RUN set -eux; \
    wget -O postgresql.tar.bz2 \
        "https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.bz2"; \
    echo "$PG_SHA256 *postgresql.tar.bz2" | sha256sum -c -; \
    mkdir -p /usr/src/postgresql; \
    tar \
        --extract \
        --file postgresql.tar.bz2 \
        --directory /usr/src/postgresql \
        --strip-components 1 \
    ; \
    rm postgresql.tar.bz2; \
    \
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
        perl-dev \
        perl-ipc-run \
        perl-utils \
        python3-dev \
        tcl-dev \
        util-linux-dev \
        zlib-dev \
        icu-dev \
        lz4-dev \
        zstd-dev \
        curl \
    ; \
    \
    cd /usr/src/postgresql; \
    # 修正默认 socket 目录
    awk '$1 == "#define" && $2 == "DEFAULT_PGSOCKET_DIR" && $3 == "\"/tmp\"" { $3 = "\"/var/run/postgresql\""; print; next } { print }' \
        src/include/pg_config_manual.h > src/include/pg_config_manual.h.new; \
    grep '/var/run/postgresql' src/include/pg_config_manual.h.new; \
    mv src/include/pg_config_manual.h.new src/include/pg_config_manual.h; \
    \
    ./configure \
        --enable-option-checking=fatal \
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
        --with-ldap \
        --with-tcl \
        --with-perl \
        --with-python \
        --with-openssl \
        --with-libxml \
        --with-libxslt \
        --with-lz4 \
        --with-zstd \
        --disable-spinlocks \
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
        zstd \
    ; \
    apk del --no-network .build-deps; \
    cd /; \
    rm -rf \
        /usr/src/postgresql \
        /usr/local/share/doc \
        /usr/local/share/man \
    ; \
    postgres --version

# 调整示例配置
RUN set -eux; \
    cp -v /usr/local/share/postgresql/postgresql.conf.sample /usr/local/share/postgresql/postgresql.conf.sample.orig; \
    sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/local/share/postgresql/postgresql.conf.sample; \
    grep -F "listen_addresses = '*'" /usr/local/share/postgresql/postgresql.conf.sample

RUN install -d -o postgres -g postgres -m 3777 /var/run/postgresql

ENV PGDATA /var/lib/postgresql/data
RUN install -d -o postgres -g postgres -m 1777 "$PGDATA"
VOLUME /var/lib/postgresql/data
RUN chmod -R a+rX /usr/local/share/postgresql /usr/local/lib/postgresql /usr/local/bin

COPY docker-entrypoint.sh docker-ensure-initdb.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-ensure-initdb.sh \  
&& ln -sfT docker-ensure-initdb.sh /usr/local/bin/docker-enforce-initdb.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

STOPSIGNAL SIGINT
EXPOSE 5432
CMD ["postgres"]
