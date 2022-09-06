# Please use "make image" to build the docker image
FROM cr.loongnix.cn/fluent/fluent-bit:1.8.11

LABEL maintainer="wangweijie@loongson.cn"

COPY conf/fluent-bit.conf conf/parsers.conf /fluent-bit/etc/
COPY fluent-bit /fluent-bit/bin/fluent-bit-watcher

#Entry point
ENTRYPOINT ["/fluent-bit/bin/fluent-bit-watcher"]
