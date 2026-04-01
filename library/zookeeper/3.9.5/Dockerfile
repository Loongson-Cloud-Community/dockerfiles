FROM cr.loongnix.cn/library/debian:buster-slim AS build
ARG TAG

RUN apt update \
    && apt install -y wget git \
    && wget -O /tmp/maven.tar.gz https://dlcdn.apache.org/maven/maven-3/3.8.9/binaries/apache-maven-3.8.9-bin.tar.gz \
    && mkdir -p /opt/maven \
    && tar -xzf /tmp/maven.tar.gz -C /opt/maven --strip-components=1 \
    && wget -O /tmp/openjdk11.deb https://ftp.loongnix.cn/Java/openjdk11/loongson11.17.26-fx-jdk11.0.30_7-linux-loongarch64.deb \
    && apt install -y /tmp/openjdk11.deb

ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH
RUN git clone -b release-${TAG} --depth 1 https://github.com/apache/zookeeper.git /tmp/zookeeper \
    && cd /tmp/zookeeper \
    && mvn clean package -Pdist -Dmaven.test.skip=true -Dmaven.javadoc.skip=true


FROM cr.loongnix.cn/library/debian:buster-slim
ARG TAG

ENV PATH=/usr/local/zookeeper/bin:${PATH} \
    ZOO_CONF_DIR=/usr/local/zookeeper/conf \
    ZOO_DATA_DIR=/data/zookeeper/data \
    ZOO_DATA_LOG_DIR=/data/zookeeper/datalog \
    ZOO_LOG_DIR=/data/zookeeper/logs

COPY --from=build /tmp/zookeeper/zookeeper-assembly/target/apache-zookeeper-${TAG}-bin.tar.gz /tmp/zookeeper.tar.gz
RUN set -eux; \
    mkdir -p /usr/local/zookeeper "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR"  "$ZOO_LOG_DIR"; \
    tar -xzf /tmp/zookeeper.tar.gz -C /usr/local/zookeeper --strip-components=1; \
    apt update; \
    apt install -y wget; \
    wget -O /tmp/openjdk17.deb https://ftp.loongnix.cn/Java/openjdk17/loongson17.17.26-fx-jdk17.0.18_8-linux-loongarch64.deb; \
    apt install -y /tmp/openjdk17.deb; \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY zoo.cfg /usr/local/zookeeper/conf/
COPY entrypoint.sh /usr/local/zookeeper/bin/

WORKDIR /usr/local/zookeeper

EXPOSE 2181 2888 3888 8080
ENTRYPOINT ["entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]
