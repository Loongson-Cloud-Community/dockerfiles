ARG ARCH="loong64"
ARG OS="linux"
FROM cr.loongnix.cn/prometheus/busybox:glibc
LABEL maintainer="wangweijie@loongson.cn"

ARG ARCH="loong64"
ARG OS="linux"
COPY --chown=nobody:nobody src/pushgateway/pushgateway /bin/pushgateway

EXPOSE 9091
RUN mkdir -p /pushgateway && chown nobody:nobody /pushgateway
WORKDIR /pushgateway

USER 65534

ENTRYPOINT [ "/bin/pushgateway" ]
