#
# Copyright 2016 Confluent Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM cr.loongnix.cn/library/debian:buster

ARG COMMIT_ID=unknown
LABEL io.confluent.docker.git.id=$COMMIT_ID
ARG BUILD_NUMBER=-1
LABEL io.confluent.docker.build.number=$BUILD_NUMBER

ARG CONFLUENT_PACKAGES_REPO=$CONFLUENT_PACKAGES_REPO

ARG ALLOW_UNSIGNED=false
#Set an env var so that it's available in derived images
ENV ALLOW_UNSIGNED=$ALLOW_UNSIGNED

MAINTAINER partner-support@confluent.io
LABEL io.confluent.docker=true

# Python
ENV PYTHON_VERSION="2.7.9-1"
ENV PYTHON_PIP_VERSION="8.1.2"

# Confluent
ENV SCALA_VERSION="2.12"

ARG KAFKA_VERSION=$KAFKA_VERSION
ARG CONFLUENT_MAJOR_VERSION=$CONFLUENT_MAJOR_VERSION
ARG CONFLUENT_MINOR_VERSION=$CONFLUENT_MINOR_VERSION
ARG CONFLUENT_PATCH_VERSION=$CONFLUENT_PATCH_VERSION

ARG CONFLUENT_MVN_LABEL=$CONFLUENT_MVN_LABEL
ARG CONFLUENT_PLATFORM_LABEL=$CONFLUENT_PLATFORM_LABEL

ENV KAFKA_VERSION=$KAFKA_VERSION
ENV CONFLUENT_MAJOR_VERSION=$CONFLUENT_MAJOR_VERSION
ENV CONFLUENT_MINOR_VERSION=$CONFLUENT_MINOR_VERSION
ENV CONFLUENT_PATCH_VERSION=$CONFLUENT_PATCH_VERSION

ENV CONFLUENT_MVN_LABEL=$CONFLUENT_MVN_LABEL
ENV CONFLUENT_PLATFORM_LABEL=$CONFLUENT_PLATFORM_LABEL

ENV CONFLUENT_VERSION="$CONFLUENT_MAJOR_VERSION.$CONFLUENT_MINOR_VERSION.$CONFLUENT_PATCH_VERSION"
ENV CONFLUENT_DEB_VERSION="1"

# Zulu-java 直接安装java
ENV ZULU_OPENJDK_VERSION="8=8.38.0.13"

# This affects how strings in Java class files are interpreted.  We want UTF-8 and this is the only locale in the
# base image that supports it
ENV LANG="C.UTF-8"

ARG DOCKER_UTILS_WHEEL_URL="https://github.com/Loongson-Cloud-Community/confluentinc_confluent-docker-utils/releases/download/v0.0.20/confluent_docker_utils-0.0.20-py2-none-any.whl"


RUN echo "===> Updating debian ....." \
    	&& echo "===> Installing curl wget netcat python...." \
    	&& DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
                apt-transport-https \
		ca-certificates \
                curl \
                git \
                wget \
		python2.7 \
		python-pip \
		python-setuptools \ 
	&& wget ${DOCKER_UTILS_WHEEL_URL} -O /confluent_docker_utils-0.0.20-py2-none-any.whl \
	&& pip2 install wheel \
    	&& pip2 install /confluent_docker_utils-0.0.20-py2-none-any.whl  \
	&& DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y openjdk-8-jre \
	&& DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y krb5-user \
	&& apt purge git -y \
    	&& rm -rf /var/lib/apt/lists/* \
    	&& rm -f /confluent_docker_utils-0.0.20-py2-none-any.whl


ENV CUB_CLASSPATH=/etc/confluent/docker/docker-utils.jar
COPY include/etc/confluent/docker /etc/confluent/docker
