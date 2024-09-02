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

ENV GOLANG_VERSION 1.21.13

RUN set -eux; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.21/abi1.0/go1.21.13.linux-loong64.tar.gz'; \
	sha256='b3c90a132d6fd39513a4d080b659360fae3c9a4c95eacbc1de1469e43fd297c4'; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
