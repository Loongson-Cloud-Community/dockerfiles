FROM cr.loongnix.cn/library/alpine:3.11

RUN apk --no-cache upgrade
RUN apk add --no-cache ca-certificates gcc musl-dev bash wget

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22.4

RUN set -eux; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.22/abi1.0/go1.22.4.linux-loong64.tar.gz'; \
	sha256='6f4c493e362569ae44c63637d05684f5d8cd4986108929d895d55c33dc9068b3'; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
