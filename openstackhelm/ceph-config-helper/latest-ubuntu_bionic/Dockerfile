ARG FROM=cr.loongnix.cn/library/debian:buster-slim
FROM ${FROM}
LABEL maintainer="wangweijie@loongson.cn"

COPY ./kubectl /usr/bin/
COPY ./pandas-0.19.2-cp37-cp37m-linux_loongarch64.whl /
COPY ./crush-1.0.35-cp37-cp37m-linux_loongarch64.whl /

RUN set -ex ;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get update ;\
    apt-get dist-upgrade -y ;\
    apt-get install --no-install-recommends -y apt-transport-https ca-certificates gnupg2 ;\
    apt-get install --no-install-recommends -y \
	ceph \
        curl \
        gcc \
        python3 \
        python3-dev \
	python3-pip \
        gdisk \
        udev \
        jq \
	cmake \
	g++ \
	libboost-chrono-dev \
	libatomic-ops-dev \
	libffi-dev \
	libssl-dev \
	libopenblas-dev

RUN set -x ;\
    pip3 install \
      setuptools==59.6.0 \
      wheel==0.37.1 ;\
    pip3 install \
      numpy==1.12.1 \
      cryptography==3.3 \
      pandas-0.19.2-cp37-cp37m-linux_loongarch64.whl \
      crush-1.0.35-cp37-cp37m-linux_loongarch64.whl \
      PyYAML \
      rgwadmin \
      six \
      s3cmd \
      python-openstackclient \
      python-swiftclient ;\
    pip3 install \
      python-cinderclient==7.2.2 \
      six==1.10.0 \
      python-keystoneclient==4.4.0 \
      python-dateutil==2.6.0 \
      pytz==2017.2 \
      packaging==16.8 \
      oslo-utils==4.2.2 ;\
    chmod +x /usr/bin/kubectl ;\
    apt-get purge -y --auto-remove \
        python3-dev \
	cmake \
        gcc ;\
    rm -rf /pandas-0.19.2-cp37-cp37m-linux_loongarch64.whl ;\
    rm -rf /crush-1.0.35-cp37-cp37m-linux_loongarch64.whl ;\
    rm -rf /var/lib/apt/lists/*
