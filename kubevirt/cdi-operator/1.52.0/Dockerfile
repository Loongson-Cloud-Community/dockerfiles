FROM cr.loongnix.cn/kubevirt/centos_base:1.52.0

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-operator \
     csv-generator \
     /usr/bin/

USER 1001

WORKDIR /home/cdi-operator

ENTRYPOINT ["/usr/bin/cdi-operator]
