FROM cr.loongnix.cn/library/debian:buster-slim AS builder
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        wget"

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG CHECK_VERSION=v1.0.2
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/healthcheck/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ check \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz

RUN set -ex \
    && mkdir -p /deployments \
    && cd /deployments \
    && wget https://github.com/fabric8io-images/run-java-sh/raw/master/fish-pepper/run-java-sh/fp-files/run-java.sh \
    && chmod +x run-java.sh

ARG VERSION=v2.7.0

RUN set -ex \
    && wget https://github.com/wojiushixiaobai/dataease/releases/download/${VERSION}/dataease-${VERSION}.tar.gz \
    && tar -xf dataease-${VERSION}.tar.gz -C /opt --strip-components=1 \
    && rm -f dataease-${VERSION}.tar.gz \
    && mkdir -p /opt/apps/config \
    && cd /opt/apps/config \
    && wget https://github.com/wojiushixiaobai/dataease/raw/master/config/application.yml

FROM cr.loongnix.cn/library/openjdk:21-slim-buster
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates"

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && echo "securerandom.source=file:/dev/urandom" >> /usr/local/openjdk-21/conf/security/java.security \
    && sed -i "s@jdk.tls.disabledAlgorithms=SSLv3, TLSv1, TLSv1.1@jdk.tls.disabledAlgorithms=SSLv3@" /usr/local/openjdk-21/conf/security/java.security \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt /opt
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /deployments/run-java.sh /deployments/run-java.sh

WORKDIR /opt/apps

ENV JAVA_APP_DIR=/deployments \
    JAVA_MAX_HEAP_RATIO=40 \
    JAVA_APP_JAR=/opt/apps/app.jar
ENV JAVA_OPTIONS="-Dfile.encoding=utf-8 -Dloader.path=/opt/apps -Dspring.config.additional-location=/opt/apps/config/"

EXPOSE 8100

CMD [ "/deployments/run-java.sh" ]