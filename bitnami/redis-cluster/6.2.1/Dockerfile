FROM cr.loongnix.cn/bitnami/minideb:buster-loong64

ENV HOME="/" \
    OS_ARCH="loong64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

COPY prebuildfs /
COPY tar-gz/redis-6.2.1-0-linux-loong64-debian-10.tar.gz /tmp/bitnami/pkg/cache/
COPY tar-gz/gosu-1.12.0-2-linux-loong64-debian-10.tar.gz /tmp/bitnami/pkg/cache/
# Install required system packages and dependencies
RUN install_packages acl ca-certificates curl gzip libc6 libssl1.1 procps tar
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "redis" "6.2.1-0" --checksum 74275011b1e2b40606d104304fc103e85f00c4cf1120e89a2517654aa7e81413
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "gosu" "1.12.0-2" --checksum 0c746b8bbdeedee266b02119a6cc55f2dc5be93d6468bf68cb89bea8d934f953
RUN chmod g+rwX /opt/bitnami


COPY rootfs /
RUN /opt/bitnami/scripts/redis-cluster/postunpack.sh
ENV BITNAMI_APP_NAME="redis-cluster" \
    BITNAMI_IMAGE_VERSION="6.2.1-debian-10-r45" \
    PATH="/opt/bitnami/redis/bin:/opt/bitnami/common/bin:$PATH"

EXPOSE 6379

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/redis-cluster/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/redis-cluster/run.sh" ]
