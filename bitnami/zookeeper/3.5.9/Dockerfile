FROM cr.loongnix.cn/library/debian:buster

ENV HOME="/" \
    OS_ARCH="loong64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/java/bin:/opt/bitnami/zookeeper/bin:$PATH"

COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages acl ca-certificates wget gzip libc6 netcat procps tar zlib1g

ARG JAVA_URL
ARG ZOOKEEPER_URL
ARG GOSU_URL
ARG WAIT_URL
RUN wget --progress=dot:giga -O openjdk.tar.gz $JAVA_URL; \
    mkdir -p /opt/bitnami/java; \
    tar --extract \
        --file openjdk.tar.gz \
        --directory "/opt/bitnami/java" \
        --strip-components 1 \
        --no-same-owner \
    ; \
    rm openjdk.tar.gz

RUN wget --progress=dot:giga -O zookeeper.tar.gz $ZOOKEEPER_URL; \
    mkdir -p /opt/bitnami/zookeeper; \
    tar --extract \
        --file zookeeper.tar.gz \
        --directory "/opt/bitnami/zookeeper" \
        --strip-components 1 \
        --no-same-owner \
    ; \
    rm zookeeper.tar.gz

RUN mkdir -p /opt/bitnami/common/bin; \
    wget -O /opt/bitnami/common/bin/gosu $GOSU_URL; \
    wget -O /opt/bitnami/common/bin/wait-for-port $WAIT_URL;

RUN apt-get update && apt-get upgrade -y && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami; \
    chmod +x /opt/bitnami/common/bin/*
RUN ln -s /opt/bitnami/scripts/zookeeper/entrypoint.sh /entrypoint.sh
RUN ln -s /opt/bitnami/scripts/zookeeper/run.sh /run.sh

COPY rootfs /
RUN /opt/bitnami/scripts/zookeeper/postunpack.sh
ENV APP_VERSION="3.5.9" \
    BITNAMI_APP_NAME="zookeeper"

EXPOSE 2181 2888 3888 8080

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/zookeeper/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/zookeeper/run.sh" ]
