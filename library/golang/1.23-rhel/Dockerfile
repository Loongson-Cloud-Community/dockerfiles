FROM cr.loongnix.cn/openanolis/anolisos:8.9

# install cgo-related dependencies
RUN set -eux; \
        yum update -y ; \
        yum install -y \
                gcc-c++ \
                gcc \
                glibc-devel \
                make \
                pkgconfig \
		wget \
        ; 

ENV PATH /usr/local/go/bin:$PATH
ENV GOLANGVERSION 1.23.12

RUN set -eux; \
	url='http://ftp.loongnix.cn/toolchain/golang/go-1.23/abi1.0/go1.23.12.linux-loong64.tar.gz'; \
	sha256='0af814e1ddfef7bf899be60e3c471eef9d2e9e9d9b1acf494e94a9f10204e16c'; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
