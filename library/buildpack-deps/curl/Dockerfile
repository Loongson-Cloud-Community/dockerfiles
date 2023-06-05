FROM cr.loongnix.cn/library/debian:buster

LABEL maintainer="wangweijie@loongson.cn"

ENV DEBIAN_FRONTEND noninteractive

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
	; \
	rm -rf /tmp/* /var/cache/apt/* /var/lib/apt/lists/*

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /tmp/* /var/cache/apt/* /var/lib/apt/lists/*; \
	fi
