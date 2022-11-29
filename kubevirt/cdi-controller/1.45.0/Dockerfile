FROM cr.loongnix.cn/kubevirt/passwd:server

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-controller /usr/bin/

USER 1001

WORKDIR /home/cdi-controller

ENTRYPOINT ["/usr/bin/cdi-controller","-alsologtostderr"]
