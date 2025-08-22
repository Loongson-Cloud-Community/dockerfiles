FROM cr.loongnix.cn/library/alpine:3.11

RUN apk --no-cache upgrade
RUN apk add --no-cache ca-certificates wget

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.24.6

RUN set -eux; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.24/abi1.0/go1.24.6.linux-loong64.tar.gz'; \
	sha256='1d8b8abb811a4991a167272d7773ac6871f9f66ab69f6c258e95aac8fe18996f'; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

RUN apk del wget

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
