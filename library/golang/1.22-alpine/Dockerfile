FROM cr.loongnix.cn/library/alpine:3.11

RUN apk add --no-cache ca-certificates

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22.0

RUN set -eux; \
	build=1; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.21/abi1.0/go1.21.5.linux-loong64.tar.gz'; \
	sha256='68c0d5ba6cdf55ab3cd26cb67fccf1ad0c9a79e3f69a99c5cafff18c88eee3f3'; \
	\
	wget -O go.tgz "$url"; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	\
	tar -C /usr/local -xzf go.tgz  && rm go.tgz; \
	cd /usr/local && mv go go-bootstrap; \
	/usr/local/go-bootstrap/bin/go version

RUN set -eux; \
	build=1; \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.22/abi1.0/go1.22.0.src.tar.gz'; \
	sha256='d8932410dbe6b9d02dc723e17ee66858e356b0e83a02bd8b1f22ab334f98ad37'; \
	export GOARCH='loong64' GOOS='linux'; \
	\
	wget -O go.tgz "$url"; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ -n "$build" ]; then \
		apk add --no-cache --virtual .build-deps \
			bash \
			gcc \
			musl-dev \
		; \
		\
		export GOCACHE='/tmp/gocache'; \
		\
		( \
			cd /usr/local/go/src; \
			# set GOROOT_BOOTSTRAP + GOHOST* such that we can build Go successfully
			export GOROOT_BOOTSTRAP="/usr/local/go-bootstrap" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
			./make.bash; \
		); \
		\
		apk del --no-network .build-deps; \
		\
		# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
			"$GOCACHE" \
			/usr/local/go-bootstrap \
		; \
	fi; \
	\
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
