FROM cr.loongnix.cn/loongson/loongnix-server:8.4 as builder

WORKDIR /

RUN dnf makecache && dnf install wget -y

RUN set -x; \
	wget -q https://github.com/Loongson-Cloud-Community/mongo/releases/download/r5.0.8/mongo-dist-5.0.8.tar.gz

RUN tar xf mongo-dist-5.0.8.tar.gz

#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM cr.loongnix.cn/library/debian:buster

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN set -eux; \
	groupadd --gid 999 --system mongodb; \
	useradd --uid 999 --system --gid mongodb --home-dir /data/db mongodb; \
	mkdir -p /data/db /data/configdb; \
	chown -R mongodb:mongodb /data/db /data/configdb

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		jq \
		numactl \
		procps \
	; \
	rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root (https://github.com/tianon/gosu/releases)
ENV GOSU_VERSION 1.17
# grab "js-yaml" for parsing mongod's YAML config files (https://github.com/nodeca/js-yaml/releases)
ENV JSYAML_VERSION 3.13.1

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		gnupg \
		wget \
		gcc \
		make \
		perl \
		zlib1g-dev \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
# download/install gosu
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/Loongson-Cloud-Community/gosu/releases/download/loongarch64-old-abi-1.17/gosu-loongarch64"; \
	\
# download/install js-yaml
	mkdir -p /opt/js-yaml/; \
	wget -O /opt/js-yaml/js-yaml.js "https://github.com/nodeca/js-yaml/raw/${JSYAML_VERSION}/dist/js-yaml.js"; \
	wget -O /opt/js-yaml/package.json "https://github.com/nodeca/js-yaml/raw/${JSYAML_VERSION}/package.json"; \
	ln -s /opt/js-yaml/js-yaml.js /js-yaml.js; \
	wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1m.tar.gz; \
	tar -xf /openssl-1.1.1m.tar.gz; \
	cd /openssl-1.1.1m && ./config && make && make install; \
#	ln -s /usr/local/lib/libssl.so.1.1 /usr/lib/loongarch64-linux-gnu/libssl.so.1.1; \
#	ln -s /usr/local/lib/libcrypto.so.1.1 /usr/lib/loongarch64-linux-gnu/libcrypto.so.1.1; \
	rm -rf /openssl-1.1.1*; \
# TODO some sort of download verification here
	\
# download/install MongoDB PGP keys
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
# smoke test
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d

# Allow build-time overrides (eg. to build image with MongoDB Enterprise version)
# Options for MONGO_PACKAGE: mongodb-org OR mongodb-enterprise
# Options for MONGO_REPO: repo.mongodb.org OR repo.mongodb.com
# Example: docker build --build-arg MONGO_PACKAGE=mongodb-enterprise --build-arg MONGO_REPO=repo.mongodb.com .
ARG MONGO_PACKAGE=mongodb-org
ARG MONGO_REPO=repo.mongodb.org
ENV MONGO_PACKAGE=${MONGO_PACKAGE} MONGO_REPO=${MONGO_REPO}

ENV MONGO_MAJOR 5.0
#RUN echo "deb [ signed-by=/etc/apt/keyrings/mongodb.asc ] http://$MONGO_REPO/apt/ubuntu focal/${MONGO_PACKAGE%-unstable}/$MONGO_MAJOR multiverse" | tee "/etc/apt/sources.list.d/${MONGO_PACKAGE%-unstable}.list"

# https://docs.mongodb.org/master/release-notes/4.4/
ENV MONGO_VERSION 5.0.8
# 02/21/2024, https://github.com/mongodb/mongo/tree/f4dda329a99811c707eb06d05ad023599f9be263
COPY --from=builder /mongo-dist-5.0.8/bin/*  /usr/bin/

RUN set -x \
	&& export DEBIAN_FRONTEND=noninteractive \
# installing "mongodb-enterprise" pulls in "tzdata" which prompts for input
	&& apt-get update \
#	&& apt-get install -y libcurl4-gnutls-dev \
	&& apt-get install -y libcurl4-openssl-dev \
#	&& ln -s /usr/lib/loongarch64-linux-gnu/libcurl.so /usr/lib/loongarch64-linux-gnu/libcurl.so.4 \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mongodb 

VOLUME /data/db /data/configdb

# ensure that if running as custom user that "mongosh" has a valid "HOME"
# https://github.com/docker-library/mongo/issues/524
ENV HOME /data/db

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 27017
CMD ["mongod"]
