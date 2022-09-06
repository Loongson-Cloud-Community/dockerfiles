# Please use "make image" to build the docker image
FROM cr.loongnix.cn/library/debian:buster-slim as builder

# Fluent Bit version
ENV FLB_MAJOR 1
ENV FLB_MINOR 8
ENV FLB_PATCH 11
ENV FLB_VERSION 1.8.11

ARG FLB_TARBALL=https://github.com/fluent/fluent-bit/archive/v$FLB_VERSION.tar.gz
ENV FLB_SOURCE $FLB_TARBALL
RUN mkdir -p /fluent-bit/bin /fluent-bit/etc /fluent-bit/log /tmp/fluent-bit-master/

ENV DEBIAN_FRONTEND noninteractive

COPY fluent-bit-v$FLB_VERSION.tar.gz /tmp/fluent-bit.tar.gz

RUN apt-get update && \
    	apt-get install -y --no-install-recommends \
    	build-essential \
    	wget \
    	ca-certificates \
    	cmake \
    	make \
    	tar \
    	libssl-dev \
    	libsasl2-dev \
    	pkg-config \
    	libsystemd-dev \
    	zlib1g-dev \
    	libpq-dev \
    	postgresql-server-dev-all \
    	flex \
    	bison

COPY luajit-2.1 /luajit-2.1

RUN cd tmp/ && mkdir fluent-bit \
	&& tar zxfv fluent-bit.tar.gz -C ./fluent-bit --strip-components=1 \
	&& mv /tmp/fluent-bit/lib/luajit-2.1.0-1e66d0f/configure /luajit-2.1/ \
	&& rm -rf /tmp/fluent-bit.tar.gz /tmp/fluent-bit/lib/luajit-2.1.0-1e66d0f \
	&& mv /luajit-2.1 /tmp/fluent-bit/lib/luajit-2.1.0-1e66d0f \
	&& wget -O ./config.sub "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" \
	&& wget -O ./config.guess "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" \
	&& cp config.guess config.sub /tmp/fluent-bit/lib/jemalloc-5.2.1/build-aux/ \
	&& cp config.guess config.sub /tmp/fluent-bit/lib/libbacktrace-ca0de05/ \
	&& cp config.guess config.sub /tmp/fluent-bit/lib/onigmo/ \
    	&& cd /tmp/fluent-bit/build/ \
    	&& rm -rf /tmp/fluent-bit/build/*

WORKDIR /tmp/fluent-bit/build/
RUN cmake -DFLB_RELEASE=On \
          -DFLB_TRACE=Off \
          -DFLB_JEMALLOC=On \
          -DFLB_TLS=On \
          -DFLB_SHARED_LIB=Off \
          -DFLB_EXAMPLES=Off \
          -DFLB_HTTP_SERVER=On \
          -DFLB_IN_SYSTEMD=On \
          -DFLB_OUT_KAFKA=On \
          -DFLB_OUT_PGSQL=On .. \
	&& make \
	&& install bin/fluent-bit /fluent-bit/bin/

# Configuration files
COPY conf/fluent-bit.conf \
     conf/parsers.conf \
     conf/parsers_ambassador.conf \
     conf/parsers_java.conf \
     conf/parsers_extra.conf \
     conf/parsers_openstack.conf \
     conf/parsers_cinder.conf \
     conf/plugins.conf \
     /fluent-bit/etc/

FROM cr.loongnix.cn/library/debian:buster-slim

LABEL maintainer="wangweijie@loongson.cn"

LABEL Description="Fluent Bit docker image" Vendor="Fluent Organization" Version="1.1"

# Copy certificates
COPY --from=builder /usr/share/ca-certificates/  /usr/share/ca-certificates/
COPY --from=builder /etc/ssl/ /etc/ssl/

# SSL stuff and needed for systemd
COPY --from=builder /usr/lib/loongarch64-linux-gnu/ /usr/lib/loongarch64-linux-gnu/
COPY --from=builder /lib/loongarch64-linux-gnu/ /lib/loongarch64-linux-gnu/


COPY --from=builder /fluent-bit /fluent-bit

EXPOSE 2020

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]   
