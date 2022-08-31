FROM cr.loongnix.cn/library/alpine:3.11.11

LABEL maintainer="wangweijie@loongson.cn"

RUN set -x \
	&& addgroup -S spiped \
	&& adduser -S -G spiped spiped

RUN apk add --no-cache libssl1.1

ENV SPIPED_VERSION=1.6.1 SPIPED_DOWNLOAD_SHA256=8d7089979db79a531a0ecc507b113ac6f2cf5f19305571eff1d3413e0ab33713

RUN set -x \
	&& apk add --no-cache --virtual .build-deps \
		curl \
		gcc \
		make \
		musl-dev \
		openssl-dev \
		tar \
	&& curl -fsSL "https://www.tarsnap.com/spiped/spiped-$SPIPED_VERSION.tgz" -o spiped.tar.gz \
	&& echo "$SPIPED_DOWNLOAD_SHA256 *spiped.tar.gz" |sha256sum -c - \
	&& mkdir -p /usr/local/src/spiped \
	&& tar xzf "spiped.tar.gz" -C /usr/local/src/spiped --strip-components=1 \
	&& rm "spiped.tar.gz" \
	&& CC=gcc make -C /usr/local/src/spiped \
	&& make -C /usr/local/src/spiped install \
	&& rm -rf /usr/local/src/spiped \
	&& apk del .build-deps

VOLUME /spiped
WORKDIR /spiped

COPY *.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["spiped"]
