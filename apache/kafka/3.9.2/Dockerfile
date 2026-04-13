###############################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

FROM cr.loongnix.cn/library/openjdk:21-buster AS build-jsa

USER root

# Get Kafka from https://archive.apache.org/dist/kafka, url passed as env var, for version 3.7.0
ENV kafka_url https://cloud.loongnix.cn/releases/loongarch64abi1/apache/kafka/3.9.2/kafka_2.13-3.9.2.tgz

COPY jsa_launch /etc/kafka/docker/jsa_launch

RUN set -eux ; \
    apt update ; \
    apt install wget procps bash -y; \
    mkdir opt/kafka; \
    wget -O kafka.tgz "$kafka_url"; \
    tar xfz kafka.tgz -C /opt/kafka --strip-components 1;

# Generate jsa files using dynamic CDS for kafka server start command and kafka storage format command
RUN /etc/kafka/docker/jsa_launch


FROM cr.loongnix.cn/library/openjdk:21-buster

# exposed ports
EXPOSE 9092

USER root

# Get Kafka from https://archive.apache.org/dist/kafka, url passed as env var, for version 3.7.0
ENV kafka_url https://cloud.loongnix.cn/releases/loongarch64abi1/apache/kafka/3.9.2/kafka_2.13-3.9.2.tgz
ENV build_date 2024-06-11


LABEL org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/apache/kafka" \
      maintainer="Apache Kafka"

RUN set -eux ; \
    apt update ; \
    apt install wget gpg gpg-agent procps bash -y; \
    mkdir opt/kafka; \
    wget -O kafka.tgz "$kafka_url"; \
    tar xfz kafka.tgz -C /opt/kafka --strip-components 1; \
    mkdir -p /var/lib/kafka/data /etc/kafka/secrets; \
    mkdir -p /etc/kafka/docker /usr/logs /mnt/shared/config; \
    useradd -m -d /home/appuser -s /bin/bash appuser; \
    chown appuser:appuser -R /usr/logs /opt/kafka /mnt/shared/config; \
    chown appuser:root -R /var/lib/kafka /etc/kafka/secrets /etc/kafka; \
    cp /opt/kafka/config/log4j.properties /etc/kafka/docker/log4j.properties; \
    cp /opt/kafka/config/tools-log4j.properties /etc/kafka/docker/tools-log4j.properties; \
    cp /opt/kafka/config/kraft/server.properties /etc/kafka/docker/server.properties; \
    chmod -R ug+w /opt/kafka /etc/kafka /var/lib/kafka /etc/kafka/secrets; \
    rm -f kafka.tgz kafka.tgz.asc KEYS; \
    apt remove wget gpg gpg-agent -y; \
    rm -rf /var/lib/apt/lists/*;

COPY --from=build-jsa kafka.jsa /opt/kafka/kafka.jsa
COPY --from=build-jsa storage.jsa /opt/kafka/storage.jsa
COPY --chown=appuser:appuser resources/common-scripts /etc/kafka/docker
COPY --chown=appuser:appuser launch /etc/kafka/docker/launch

USER appuser

VOLUME ["/etc/kafka/secrets", "/var/lib/kafka/data", "/mnt/shared/config"]

CMD ["/etc/kafka/docker/run"]
