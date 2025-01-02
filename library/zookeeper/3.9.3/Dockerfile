FROM cr.loongnix.cn/library/debian:buster-slim AS builder

ENV HOME="/" \
    OS_ARCH="loong64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux" \
    PATH="/opt/java/bin:/opt/zooKeeper/bin:$PATH" \
    ZOO_CFG_DIR="/opt/zooKeeper/conf" \
    ZOO_DATA_DIR="/data/zooKeeper/data" \
    ZOO_DATA_LOG_DIR="/data/zooKeeper/datalog" \
    ZOO_LOG_DIR="/data/zooKeeper/logs"

VOLUME /data
RUN apt-get update&& DEBIAN_FRONTEND=noninteractive apt-get install -y wget\
    && apt-get install -y tar
RUN mkdir -p "/opt/zooKeeper" "/opt/java"
COPY src/zookeeper/zookeeper-assembly/target/zookeeper /opt/zooKeeper
RUN wget http://ftp.loongnix.cn/Java/openjdk11/loongson11.3.0-fx-jdk11.0.17_8-linux-loongarch64.tar.gz \
    && tar --extract --file loongson11.3.0-fx-jdk11.0.17_8-linux-loongarch64.tar.gz --directory "/opt/java"  --strip-components 1\
    && rm loongson11.3.0-fx-jdk11.0.17_8-linux-loongarch64.tar.gz

WORKDIR /opt/java/
RUN ls
RUN mkdir -p $ZOO_CFG_DIR $ZOO_DATA_DIR $ZOO_DATA_LOG_DIR

COPY zoo.cfg /opt/zooKeeper/conf/
COPY entrypoint.sh /opt/zooKeeper/bin/
RUN chmod +x /opt/zooKeeper/bin/*
WORKDIR /opt/zooKeeper/bin/
RUN ls

EXPOSE 2181 2888 3888 8080
ENTRYPOINT ["/opt/zooKeeper/bin/entrypoint.sh"]
CMD ["/opt/zooKeeper/bin/zkServer.sh", "start-foreground"]
