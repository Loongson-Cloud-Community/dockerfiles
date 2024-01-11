FROM cr.loongnix.cn/library/debian:buster-slim

ARG DEPENDENCIES=" \
		ca-certificates \
		curl \
		libcap2-bin \
		wget"

ARG DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
	apt-get update; \
	apt-get install -y --no-install-recommends $DEPENDENCIES; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	mkdir -p \
		/config/caddy \
		/data/caddy \
		/etc/caddy \
		/usr/share/caddy \
	; \
	wget -O /etc/caddy/Caddyfile "https://github.com/caddyserver/dist/raw/cd39178d252a610fee6aa8465c787d9c780007a2/config/Caddyfile"; \
	wget -O /usr/share/caddy/index.html "https://github.com/caddyserver/dist/raw/cd39178d252a610fee6aa8465c787d9c780007a2/welcome/index.html"

# https://github.com/caddyserver/caddy/releases
ARG CADDY_VERSION
ENV CADDY_VERSION=${CADDY_VERSION}

RUN set -eux; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	case "$arch" in \
		amd64)  binArch='amd64';; \
		arm64) binArch='arm64';; \
		ppc64el|ppc64le) binArch='ppc64le';; \
		s390x)   binArch='s390x';; \
		riscv64) binArch='riscv64';; \
		loong64|loongarch64) binArch='loong64';; \
		*) echo >&2 "error: unsupported architecture ($arch)"; exit 1 ;;\
	esac; \
	wget -O /tmp/caddy.tar.gz "https://github.com/wojiushixiaobai/caddy-loongarch64/releases/download/${CADDY_VERSION}/caddy_${CADDY_VERSION#v}_linux_${binArch}.tar.gz"; \
	tar x -z -f /tmp/caddy.tar.gz -C /usr/bin caddy; \
	rm -f /tmp/caddy.tar.gz; \
	setcap cap_net_bind_service=+ep /usr/bin/caddy; \
	chmod +x /usr/bin/caddy; \
	caddy version

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

LABEL org.opencontainers.image.version=${CADDY_VERSION}
LABEL org.opencontainers.image.title=Caddy
LABEL org.opencontainers.image.description="a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go"
LABEL org.opencontainers.image.url=https://caddyserver.com
LABEL org.opencontainers.image.documentation=https://caddyserver.com/docs
LABEL org.opencontainers.image.vendor="Light Code Labs"
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.source="https://github.com/caddyserver/caddy-docker"

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]