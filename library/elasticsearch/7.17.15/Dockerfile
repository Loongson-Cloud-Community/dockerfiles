ARG TAG=$TAG

FROM cr.loongnix.cn/library/debian:buster-slim AS build
ARG TAG

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt install -y --no-install-recommends git wget jq ca-certificates \
    && wget -O openjdk17.deb https://ftp.loongnix.cn/Java/openjdk17/loongson17.17.26-fx-jdk17.0.18_8-linux-loongarch64.deb \
    && wget -O openjdk21.deb https://ftp.loongnix.cn/Java/openjdk21/loongson21.10.25-fx-jdk21.0.10_7-linux-loongarch64.deb \
    && apt install -y --no-install-recommends ./*.deb \
    && mv /usr/lib/jvm/loongson-jdk17-fx-loongarch64 /usr/lib/jvm/java-17-openjdk \
    && mv /usr/lib/jvm/loongson-jdk21-fx-loongarch64 /usr/lib/jvm/java-21-openjdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace    
RUN git clone https://github.com/loongarch64-releases/elasticsearch.git /workspace \
    && sed -i 's@https://maven.loongnix.cn/loongarch/maven@https://maven.loongnix.cn/loongarchabi1/maven@' /workspace/patches/patch.sh \
    && ./process_version.sh ${TAG}
 

FROM cr.loongnix.cn/library/debian:buster-slim AS prepare
ARG TAG

RUN for iter in 1 2 3 4 5 6 7 8 9 10; do \
      apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget && \
      exit_code=0 && break || \
        exit_code=$? && echo "apt-get error: retry $iter in 10s" && sleep 10; \
    done; \
    exit $exit_code

RUN mkdir /usr/share/elasticsearch
WORKDIR /usr/share/elasticsearch

COPY --from=build /workspace/dists/${TAG}/elasticsearch-${TAG}-linux-loongarch64.tar.gz /tmp/elasticsearch.tar.gz

RUN tar -zxf /tmp/elasticsearch.tar.gz \
        --strip-components=1 \
        --no-same-owner \
        --no-same-permissions

COPY config/elasticsearch.yml config/
COPY config/log4j2.properties config/log4j2.docker.properties

RUN sed -i -e 's/ES_DISTRIBUTION_TYPE=tar/ES_DISTRIBUTION_TYPE=docker/' bin/elasticsearch-env && \
    mkdir data && \
    mv config/log4j2.properties config/log4j2.file.properties && \
    mv config/log4j2.docker.properties config/log4j2.properties && \
    find . -type d -exec chmod 0555 {} + && \
    find . -type f -exec chmod 0444 {} + && \
    chmod 0555 bin/* jdk/bin/* jdk/lib/jspawnhelper && \
    chmod 0775 bin config config/jvm.options.d data logs plugins && \
    find config -type f -exec chmod 0664 {} +


FROM cr.loongnix.cn/library/debian:buster-slim
ARG TAG

RUN yes no | dpkg-reconfigure dash && \
    for iter in 1 2 3 4 5 6 7 8 9 10; do \
      export DEBIAN_FRONTEND=noninteractive && \
      apt-get update && \
      apt-get upgrade -y && \
      apt-get install -y --no-install-recommends \
        ca-certificates curl netcat-openbsd p11-kit unzip zip passwd tini && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* && \
      exit_code=0 && break || \
        exit_code=$? && echo "apt-get error: retry $iter in 10s" && sleep 10; \
    done; \
    exit $exit_code

RUN mkdir -p /usr/share/elasticsearch && \
    groupadd -g 1000 elasticsearch && \
    useradd -u 1000 -g 1000 -d /usr/share/elasticsearch -s /bin/bash elasticsearch && \
    usermod -aG root elasticsearch && \
    chown -R 0:0 /usr/share/elasticsearch

ENV ELASTIC_CONTAINER true

WORKDIR /usr/share/elasticsearch

COPY --from=prepare --chown=0:0 /usr/share/elasticsearch /usr/share/elasticsearch

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV SHELL /bin/bash

COPY bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod g=u /etc/passwd && \
    chmod 0555 /usr/local/bin/docker-entrypoint.sh && \
    find / -xdev -perm -4000 -exec chmod ug-s {} + && \
    chmod 0775 /usr/share/elasticsearch && \
    chown elasticsearch bin config config/jvm.options.d data logs plugins

COPY bin/docker-openjdk /etc/ca-certificates/update.d/docker-openjdk
RUN /etc/ca-certificates/update.d/docker-openjdk

EXPOSE 9200 9300

LABEL org.label-schema.name="Elasticsearch" \
  org.label-schema.version="${TAG}" \
  org.opencontainers.image.title="Elasticsearch" \
  org.opencontainers.image.version="${TAG}"

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["eswrapper"]

USER 1000:0
