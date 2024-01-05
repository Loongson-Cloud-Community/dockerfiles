FROM cr.loongnix.cn/kubevirt/centos_base:1.52.0

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-cloner \
     cloner_startup.sh \
     /usr/bin/

ENTRYPOINT ["/usr/bin/cloner_startup.sh"]
