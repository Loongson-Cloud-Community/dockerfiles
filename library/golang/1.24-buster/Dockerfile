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
ENV GOLANGVERSION 1.24.6

RUN set -eux; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.24/abi1.0/go1.24.6.linux-loong64.tar.gz'; \
	sha256='1d8b8abb811a4991a167272d7773ac6871f9f66ab69f6c258e95aac8fe18996f'; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
