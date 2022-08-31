FROM cr.loongnix.cn/library/debian:buster-slim

LABEL maintainer="wangweijie@loongson.cn"

RUN set -x \
	&& groupadd -r spiped \
	&& useradd -r -g spiped spiped

RUN export DEBIAN_FRONTEND="noninteractive" \
	&& set -x \
	&& apt-get update \
	&& apt-get install -y libssl1.1 --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

ENV SPIPED_VERSION=1.6.2 SPIPED_DOWNLOAD_SHA256=05d4687d12d11d7f9888d43f3d80c541b7721c987038d085f71c91bb06204567

RUN export DEBIAN_FRONTEND="noninteractive" \
	&& set -x \
	&& buildDeps='libssl-dev libc-dev gcc make curl ca-certificates' \
	&& apt-get update \
	&& apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& curl -fsSL "https://www.tarsnap.com/spiped/spiped-$SPIPED_VERSION.tgz" -o spiped.tar.gz \
	&& echo "$SPIPED_DOWNLOAD_SHA256 *spiped.tar.gz" |sha256sum -c - \
	&& mkdir -p /usr/local/src/spiped \
	&& tar xzf "spiped.tar.gz" -C /usr/local/src/spiped --strip-components=1 \
	&& rm "spiped.tar.gz" \
	&& CC=gcc make -C /usr/local/src/spiped \
	&& make -C /usr/local/src/spiped install \
	&& rm -rf /usr/local/src/spiped \
	&& apt-get purge -y --auto-remove $buildDeps

VOLUME /spiped
WORKDIR /spiped

COPY *.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["spiped"]
