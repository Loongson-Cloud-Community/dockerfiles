# Copyright 2020 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file creates a standard build environment for building cross
# platform go binary for the architecture kubernetes cares about.

FROM cr.loongnix.cn/library/golang:1.19

##------------------------------------------------------------
# global ARGs & ENVs
ARG DEBIAN_FRONTEND=noninteractive

ENV GOARM 7
ENV KUBE_DYNAMIC_CROSSPLATFORMS \
  arm64 \
  armhf \
  i386 \
  ppc64el \
  s390x

ENV KUBE_CROSSPLATFORMS \
  linux/loong64

##------------------------------------------------------------

# Pre-compile the standard go library when cross-compiling. This is much easier now when we have go1.5+
RUN targetArch=$(echo $TARGETPLATFORM | cut -f2 -d '/') \
    && if [ ${targetArch} = "amd64" ]; then \
    for platform in ${KUBE_CROSSPLATFORMS}; do GOOS=${platform%/*} GOARCH=${platform##*/} go install std; done \
    && go clean -cache; \
fi

# Install packages
RUN apt-get -q update \
    && apt-get install -qqy \
        apt-utils \
        file \
        jq \
        patch \
        rsync \
        unzip \
        iproute2

# Use dynamic cgo linking for architectures other than amd64 for the server platforms
# To install crossbuild essential for other architectures add the following repository.
RUN apt-get update \
    && apt-get install -y build-essential 

RUN mkdir /tmp/protoc && cd /tmp/protoc \
  && wget "https://github.com/Loongson-Cloud-Community/protobuf/releases/download/v3.21.12/protoc-3.21.12-linux-loongarch_64.zip" \
  && unzip "protoc-3.21.12-linux-loongarch_64.zip" \
  && chmod -R +rX /tmp/protoc \
  && cp -pr bin /usr/local \
  && cp -pr include /usr/local \
  && rm -rf /tmp/protoc \
  && protoc --version

# work around 64MB tmpfs size in Docker 1.6
ENV TMPDIR /tmp.k8s
RUN mkdir $TMPDIR \
  && chmod a+rwx $TMPDIR \
  && chmod o+t $TMPDIR

# Get the code coverage tool and goimports
RUN for i in {1..5}; do GOPROXY="direct" go install golang.org/x/tools/cmd/cover@latest && break || sleep 15; done  \
    && for i in {1..5}; do GOPROXY="direct" go install golang.org/x/tools/cmd/goimports@latest && break || sleep 15; done  \
    && go clean -cache

# Cleanup a bit
RUN apt-get -qqy remove \
      wget \
    && apt-get clean \
    && rm -rf -- \
        /var/lib/apt/lists/*

ENTRYPOINT []
