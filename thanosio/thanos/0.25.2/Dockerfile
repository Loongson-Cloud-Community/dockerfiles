# Please use "make image" to build the docker image 
FROM cr.loongnix.cn/prometheus/busybox:glibc

LABEL maintainer="wangweijie@loongson.cn"

COPY thanos /bin/thanos

ENTRYPOINT ["/bin/thanos"] 
