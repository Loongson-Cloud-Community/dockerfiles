FROM cr.loongnix.cn/kubevirt/passwd:server

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-apiserver /usr/bin/

USER 1001

WORKDIR /home/cdi-apiserver

ENTRYPOINT ["/usr/bin/cdi-apiserver","-alsologtostderr"]
