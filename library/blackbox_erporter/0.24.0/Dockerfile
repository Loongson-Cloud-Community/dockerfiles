ARG ARCH="loongarch64"
ARG OS="linux"
FROM cr.loongnix.cn/library/busybox:1.29.3
LABEL maintainer="Zewei Yang <yangzewei@loongson.cn>"

ARG ARCH="loongarch64"
ARG OS="linux"
ADD blackbox_exporter  /bin/blackbox_exporter
ADD blackbox.yml       /etc/blackbox_exporter/config.yml

EXPOSE      9115
ENTRYPOINT  [ "/bin/blackbox_exporter" ]
CMD         [ "--config.file=/etc/blackbox_exporter/config.yml" ]
