FROM cr.loongnix.cn/kubevirt/centos_base:1.52.0

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-uploadproxy /usr/bin/

USER 1001

WORKDIR /home/cdi-uploadproxy

ENTRYPOINT ["/usr/bin/cdi-uploadproxy","-alsologtostderr"]
