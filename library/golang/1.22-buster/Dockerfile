FROM cr.loongnix.cn/library/buildpack-deps:buster-scm

# install cgo-related dependencies
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	; \
	apt-get autoclean all; \
	rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH
ENV GOLANGVERSION 1.22.6

RUN set -eux; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.22/abi1.0/go1.22.6.linux-loong64.tar.gz'; \
	sha256='4970e63c688c248f995b8bc3378377984adb8e7d652c3e8dca909050d3d94f82'; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
