FROM        cr.loongnix.cn/library/busybox:1.30.1
MAINTAINER  qiangxuhui <qiangxuhui@loongson.cn>

COPY kafka_exporter /bin/kafka_exporter

EXPOSE     9308
ENTRYPOINT [ "/bin/kafka_exporter" ]
