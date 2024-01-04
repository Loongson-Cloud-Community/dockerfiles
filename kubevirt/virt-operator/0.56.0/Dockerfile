FROM cr.loongnix.cn/kubevirt/passwd:server

LABEL maintainer="wangweijie@loongson.cn"

COPY .version /.version

COPY ./virt-operator /usr/bin/

COPY ./csv-generator /usr/bin/

USER 1001

ENTRYPOINT ["/usr/bin/virt-operator"]
