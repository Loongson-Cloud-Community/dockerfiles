#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM cr.loongnix.cn/library/alpine:3.11

RUN apk add --no-cache \
		ca-certificates \
		wget \
# Workaround for golang not producing a static ctr binary on Go 1.15 and up https://github.com/containerd/containerd/issues/5824
		libc6-compat \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client

# ensure that nsswitch.conf is set up for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/moby/moby/blob/v20.10.21/hack/make.sh#L115
# - https://github.com/golang/go/blob/go1.19.3/src/net/conf.go#L227-L303
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
#RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf
RUN if [ -e /etc/nsswitch.conf ]; then grep '^hosts: files dns' /etc/nsswitch.conf || true; fi


ENV DOCKER_VERSION 23.0.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-23.0.1.tgz'; \
			;; \
                'loongarch64') \
                        url='https://github.com/Loongson-Cloud-Community/moby/releases/download/loong64-v23.0.4/docker-23.0.4.tgz'; \
                        ;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-23.0.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-23.0.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-23.0.1.tgz'; \
			;; \
		*) echo >&2 "error: unsupported 'docker.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'docker.tgz' "$url"; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		--no-same-owner \
		'docker/docker' \
	; \
	rm docker.tgz; \
	\
	docker --version

ENV DOCKER_BUILDX_VERSION 0.10.4
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-amd64'; \
			sha256='dbe68cdc537d0150fc83e3f30974cd0ca11c179dafbf27f32d6f063be26e869b'; \
			;; \
                'loongarch64') \
                        url='https://github.com/Loongson-Cloud-Community/buildx/releases/download/0.10.4/buildx'; \
                        sha256='228ce2e8770546feacd26f192ff62611b000f51d09774ee672d56ddd2c6c6158'; \
                        ;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-arm-v6'; \
			sha256='d50aa01a22a53e5a0eae9918274c9931b813b5336c0e30061a6b1904efb0c5eb'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-arm-v7'; \
			sha256='aabc8cef5b9221ecbcb0af9846004a30591540be8668504d70814efe870448c8'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-arm64'; \
			sha256='e8f666134cf4aa83ec2b1b6afef0c83b1ea1387984d7a40ae6657b7da4d82d91'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-ppc64le'; \
			sha256='d107178f36e6c83286f3f9316e2f66b18f08306570cef209cb5840c880bd91ae'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-riscv64'; \
			sha256='393db8518aeb442d0ca5f3ccf4800622dfc5eb8993c29bbfccb023cbfde6cdbc'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-s390x'; \
			sha256='16ce9071c14293640e9bcd547ff01578c65cfc68fc6c154091abd81daaf10929'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-buildx' architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-buildx' "$url"; \
	echo "$sha256 *"'docker-buildx' | sha256sum -c -; \
	\
	plugin='/usr/libexec/docker/cli-plugins/docker-buildx'; \
	mkdir -p "$(dirname "$plugin")"; \
	mv 'docker-buildx' "$plugin"; \
	chmod +x "$plugin"; \
	mkdir -p $HOME/.docker/cli-plugins/ ;\
	cp /usr/libexec/docker/cli-plugins/docker-buildx $HOME/.docker/cli-plugins/docker-buildx ; \
	docker buildx version;

ENV DOCKER_COMPOSE_VERSION 2.16.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64'; \
			sha256='54ab01967b05e392e6bf13afbc654146890b9fa40501b40aca83a2db18f10427'; \
			;; \
                'loongarch64') \
                        url='https://github.com/Loongson-Cloud-Community/compose/releases/download/v2.16.0/docker-compose-linux-loongarch64'; \
                        sha256='78bafe741a3ec72a5ae4bcd1a5a34fa6c5c615ee59c8a8237457a321ff700cd6'; \
                        ;; \

		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-armv6'; \
			sha256='59caa4c31a6515a81b44446d978891c5e1d0f460b9b11e38dea27e1bffdb4cd6'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-armv7'; \
			sha256='558a083683bd597f5e167178dbdbe57824eecf2132bfb497a58f5d39c5e49e8a'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-aarch64'; \
			sha256='edaf196a0b9ebe749aa1a42a6ce4550d2c6c2620762aa98c36088a9b96fd22ef'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-ppc64le'; \
			sha256='aac719dc81ef117bdcca96d7e43ecd605ebcdc1df77c0b09b9d5faf15ccf952e'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-riscv64'; \
			sha256='8c485ee45cf6be4d483179e925ffeb3b046280d1be045cdfc999c0a011ddfcd1'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-s390x'; \
			sha256='fbaff480bd7901c31ead046652c3f5a3c1236766ce9f52fadfa935a18dd463b8'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-compose' architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-compose' "$url"; \
	echo "$sha256 *"'docker-compose' | sha256sum -c -; \
	\
	plugin='/usr/libexec/docker/cli-plugins/docker-compose'; \
	mkdir -p "$(dirname "$plugin")"; \
	mv 'docker-compose' "$plugin"; \
	chmod +x "$plugin"; \
	\
	ln -sv "$plugin" /usr/local/bin/; \
	docker-compose --version; \
	docker compose version

COPY modprobe.sh /usr/local/bin/modprobe
COPY docker-entrypoint.sh /usr/local/bin/

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

#ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
