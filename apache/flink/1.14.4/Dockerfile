FROM cr.loongnix.cn/library/openjdk:11

LABEL maintainer shanjiantao@loongson.cn

RUN set -ex; \
  apt-get update; \
  apt-get -y install gpg libsnappy1v5 gettext-base libjemalloc-dev; \
  rm -rf /var/lib/apt/lists/*

ENV GOSU_DOWNLOAD https://github.com/Loongson-Cloud-Community/gosu/releases/download/1.12/gosu-loongarch64
RUN set -ex; \
  wget -nv -O /usr/local/bin/gosu "$GOSU_DOWNLOAD"; \
  chmod +x /usr/local/bin/gosu; \
  gosu nobody true

ENV FLINK_HOME /opt/flink
ENV PATH=$FLINK_HOME/bin:$PATH

RUN groupadd --system --gid=9999 flink && \
    useradd --system --home-dir $FLINK_HOME --uid=9999 --gid=flink flink
WORKDIR $FLINK_HOME

# Install Flink
ENV FLINK_DOWNLOAD https://github.com/Loongson-Cloud-Community/flink/releases/download/release-1.14.4/flink-1.14.4-bin-scala_2.12.tgz
RUN set -ex; \
  wget -nv -O flink.tgz "$FLINK_DOWNLOAD"; \
  tar -xf flink.tgz --strip-components=1; \
  rm flink.tgz; \
  \
  chown -R flink:flink .;

# Configure container
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 6123 8081
CMD ["help"]

