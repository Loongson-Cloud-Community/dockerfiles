FROM cr.loongnix.cn/library/debian:buster-slim

LABEL maintainer="wangweijie@loongson.cn"

ENV DEBIAN_FRONTEND noninteractive

RUN set -eux; \
	groupadd --gid 99 --system haproxy; \
	useradd \
		--gid haproxy \
		--home-dir /var/lib/haproxy \
		--no-create-home \
		--system \
		--uid 99 \
		haproxy \
	; \
	mkdir /var/lib/haproxy; \
	chown haproxy:haproxy /var/lib/haproxy

ENV HAPROXY_VERSION 2.3.10
ENV HAPROXY_URL https://www.haproxy.org/download/2.3/src/haproxy-$HAPROXY_VERSION.tar.gz
ENV HAPROXY_SHA256=9946e0cfc83f29072b3431e37246221cf9d4a9d28a158c075714d345266f4f35

RUN set -eux; \
	\
	apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		gcc \
		libc6-dev \
		liblua5.3-dev \
		libpcre2-dev \
		libssl-dev \
		make \
		wget \
		zlib1g-dev \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	wget -O haproxy.tar.gz "$HAPROXY_URL"; \
	echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c; \
	mkdir -p /usr/src/haproxy; \
	tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1; \
	rm haproxy.tar.gz; \
	\
	makeOpts=' \
		TARGET=linux-glibc \
		USE_GETADDRINFO=1 \
		USE_LUA=1 LUA_INC=/usr/include/lua5.3 \
		USE_OPENSSL=1 \
		USE_PCRE2=1 USE_PCRE2_JIT=1 \
		USE_ZLIB=1 \
		\
		EXTRA_OBJS=" \
			contrib/prometheus-exporter/service-prometheus.o \
		" \
	'; \
	dpkgArch="$(dpkg --print-architecture)"; \
	case "$dpkgArch" in \
		armel) makeOpts="$makeOpts ADDLIB=-latomic" ;; \
	esac; \
	\
	nproc="$(nproc)"; \
	eval "make -C /usr/src/haproxy -j '$nproc' all $makeOpts"; \
	eval "make -C /usr/src/haproxy install-bin $makeOpts"; \
	\
	mkdir -p /usr/local/etc/haproxy; \
	cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors; \
	rm -rf /usr/src/haproxy; \
	\
	haproxy -v

STOPSIGNAL SIGUSR1

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

# no USER for backwards compatibility (to try to avoid breaking existing users)
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
