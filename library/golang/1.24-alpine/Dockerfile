FROM cr.loongnix.cn/library/alpine:3.11

RUN apk --no-cache upgrade
RUN apk add --no-cache ca-certificates wget

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.24.3

RUN set -eux; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.24/abi1.0/go1.24.3.linux-loong64.tar.gz'; \
	sha256='0a1756373a86a84f420cf74045665ed83f7165fdc0b36c87f63c4b29779ac840'; \
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
