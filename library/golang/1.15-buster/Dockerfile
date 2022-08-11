FROM cr.loongnix.cn/library/buildpack-deps:buster-scm

LABEl maintainer="shanjiantao@longson.cn"

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.15.6

RUN set -eux; \
	url="https://github.com/Loongson-Cloud-Community/go/releases/download/go1.15.6-loongarch64/golang1.15.6.linux-loong64.tar.gz"; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
