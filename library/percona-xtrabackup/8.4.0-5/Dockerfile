FROM cr.loongnix.cn/library/mysql:8.4.8 AS prepare

RUN yum -y update && \
    yum -y install wget && \
    yum clean all

RUN wget -O /tmp/percona-xtrabackup-8.4.0.tar.gz http://cloud.loongnix.cn/releases/loongarch64abi1/percona%2Fpercona-xtrabackup%2F8.4.0-5/percona-xtrabackup-8.4.0-linux-loongarch64.tar.gz && \
    mkdir -p /opt/percona-xtrabackup && \
    tar -xzf /tmp/percona-xtrabackup-8.4.0.tar.gz -C /opt/percona-xtrabackup --strip-component=1 && \
    rm -f /tmp/percona-xtrabackup-8.4.0.tar.gz


FROM cr.loongnix.cn/loongson/loongnix-server:8.4

RUN yum -y update && \
    yum -y install \
        glibc-langpack-en \
        tar \
        unzip \
        shadow-utils \
        socat \
        hostname \
        jq \
        procps-ng \
        lz4 \
        zstd \
        ncurses-libs \
        libev \
        libaio \
        devtoolset-10-libstdc++ && \
    yum clean all

RUN ln -sf /opt/rh/devtoolset-10/root/usr/lib/libstdc++.so.6 /lib64/libstdc++.so.6
RUN groupadd -g 1001 mysql && \
    useradd -u 1001 -r -g 1001 -s /sbin/nologin \
            -c "Default Application User" mysql

COPY --from=prepare /usr/bin/mysql /usr/bin/mysql
COPY --from=prepare /usr/bin/mysqlbinlog /usr/bin/mysqlbinlog
COPY --from=prepare /opt/percona-xtrabackup /usr/local/percona-xtrabackup
RUN chmod +x /usr/bin/mysql /usr/bin/mysqlbinlog
ENV PATH=/usr/local/percona-xtrabackup/bin:$PATH

RUN install -d -o 1001 -g 0 -m 0775 /backup
WORKDIR /backup

COPY pxb-entry.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME [ "/backup" ]
USER 1001
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["xtrabackup"]
