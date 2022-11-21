FROM cr.loongnix.cn/kubevirt/passwd:0.50.0

LABEL maintainer="wangweijie@loongson.cn"

COPY .version /

COPY virt-controller /usr/bin/

USER 1001

ENTRYPOINT ["/usr/bin/virt-controller"]
