FROM cr.loongnix.cn/kubevirt/centos_base:1.52.0

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-apiserver /usr/bin/

USER 1001

WORKDIR /home/cdi-apiserver

ENTRYPOINT ["/usr/bin/cdi-apiserver","-alsologtostderr"]
