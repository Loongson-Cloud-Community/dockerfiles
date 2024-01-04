FROM cr.loongnix.cn/kubevirt/passwd:server

LABEL maintainer="wangweijie@loongson.cn"

COPY .version /.version

COPY virt-controller /usr/bin/

USER 1001

ENTRYPOINT ["/usr/bin/virt-controller"]
