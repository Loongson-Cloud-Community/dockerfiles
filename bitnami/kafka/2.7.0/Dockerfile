FROM cr.loongnix.cn/library/debian:buster

ENV HOME="/" \
    OS_ARCH="loong64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages acl ca-certificates wget gzip libc6 procps tar zlib1g

ARG JAVA_URL
ARG KAFKA_URL
ARG GOSU_URL
ARG WAIT_URL
ARG RENDER_URL
RUN wget --progress=dot:giga -O openjdk.tar.gz $JAVA_URL; \
    mkdir -p /opt/bitnami/java; \
    tar --extract \
	--file openjdk.tar.gz \
	--directory "/opt/bitnami/java" \
	--strip-components 1 \
	--no-same-owner \
    ; \
    rm openjdk.tar.gz

RUN wget --progress=dot:giga -O kafka.tgz $KAFKA_URL; \
    mkdir -p /opt/bitnami/kafka; \
    tar --extract \
	--file kafka.tgz \
	--directory "/opt/bitnami/kafka" \
	--strip-components 1 \
	--no-same-owner \
    ; \
    rm kafka.tgz

RUN mkdir -p /opt/bitnami/common/bin; \
    wget -O /opt/bitnami/common/bin/gosu $GOSU_URL; \
    wget -O /opt/bitnami/common/bin/wait-for-port $WAIT_URL; \
    wget -O /opt/bitnami/common/bin/render-template $RENDER_URL

RUN chmod g+rwX /opt/bitnami; \
    chmod +x /opt/bitnami/common/bin/*
RUN ln -s /opt/bitnami/scripts/kafka/entrypoint.sh /entrypoint.sh
RUN ln -s /opt/bitnami/scripts/kafka/run.sh /run.sh

COPY rootfs /
RUN /opt/bitnami/scripts/kafka/postunpack.sh
ENV BITNAMI_APP_NAME="kafka" \
    BITNAMI_IMAGE_VERSION="2.7.0-debian-10-r124" \
    PATH="/opt/bitnami/java/bin:/opt/bitnami/common/bin:/opt/bitnami/kafka/bin:$PATH"

EXPOSE 9092

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/kafka/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/kafka/run.sh" ]
