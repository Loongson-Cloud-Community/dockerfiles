FROM cr.loongnix.cn/library/alpine:3.11

RUN apk add --no-cache ca-certificates

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.20.6

# Bootstrap for Go1.20 requires minimum Go1.17, now build Go1.19 as bootstrap for Go1.20.x
RUN set -eux; \
	build=1; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.19/abi1.0/go1.19.7.src.tar.gz'; \
	sha256='3b423c46d1ed679520bb8af7bf28594f93b2a81854d7fd22320f569f7dc4715d'; \
	export GOARCH='loong64' GOOS='linux'; \
	\
	wget -O go.tgz "$url"; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	apk add --no-cache --virtual .build-deps bash gcc go musl-dev; \
	\
	cd /usr/local/go/src; \
	export GOCACHE='/tmp/gocache'; \
	export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
	./make.bash; \
	\
	cd ../../ && mv go go-bootstrap; \
	rm -rf "$GOCACHE"; \
	\
	/usr/local/go-bootstrap/bin/go version


RUN set -eux; \
	build=1; \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.20/abi1.0/go1.20.6.src.tar.gz'; \
	sha256='e1543072bad7696bce60715ef7a15cf22634cd5c330accdeced4df7d81d6395b'; \
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
			go \
			musl-dev \
		; \
		\
		export GOCACHE='/tmp/gocache'; \
		\
		( \
			cd /usr/local/go/src; \
# set GOROOT_BOOTSTRAP + GOHOST* such that we can build Go successfully
			export GOROOT_BOOTSTRAP="/usr/local/go-bootstrap" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
			if [ "${GOARCH:-}" = '386' ]; then \
# https://github.com/golang/go/issues/52919; https://github.com/docker-library/golang/pull/426#issuecomment-1152623837
				export CGO_CFLAGS='-fno-stack-protector'; \
			fi; \
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
