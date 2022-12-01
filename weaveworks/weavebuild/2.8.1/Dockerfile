FROM cr.loongnix.cn/library/golang:1.15-buster

LABEL maintainer="wangweijie@loongson.cn"

ENV DEB_CROSSPLATFORMS loongarch64

ENV GO_CROSSPLATFORMS linux/loong64

ENV GCC_CROSSCOMPILERS loongarch64-linux-gnu

# Install the build-essential and crossbuild-essential-ARCH packages
RUN for platform in ${DEB_CROSSPLATFORMS}; do dpkg --add-architecture $platform; done \
  && apt-get update \
  && apt-get install -y build-essential \
  && for platform in ${DEB_CROSSPLATFORMS}; do apt-get install -y crossbuild-essential-${platform}; done \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install some required packages
# libpcap is required because we're linking against its C libraries from the prog/weaver binary
# flex and bison are required packages for compiling libpcap manually later
RUN apt-get update \
	&& apt-get install -y \
		libpcap-dev \
		python-requests \
		time \
		file \
		flex \
		bison \
		wget


# Install common Go tools
RUN go version \
	&& go env -w GO111MODULE=on \
	&& go env -w GOPROXY=https://goproxy.cn,direct \
	&& export GOSUMDB=off \
	&& go get -v \
    	github.com/weaveworks/build-tools/cover \
    	github.com/mattn/goveralls \
	golang.org/x/lint/golint \
	github.com/fzipp/gocyclo@v0.3.1 \
	github.com/fatih/hclfmt \
	github.com/client9/misspell/cmd/misspell

# Allow full write access to the Go folders for anyone
RUN chmod -R a+w /usr/local/go


ENV LIBPCAP_CROSS_VERSION=1.6.2
RUN curl -sSL https://www.tcpdump.org/release/libpcap-${LIBPCAP_CROSS_VERSION}.tar.gz | tar -xz \
	&& cd libpcap-${LIBPCAP_CROSS_VERSION} \
	&& wget -O ./config.sub "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" \
	&& wget -O ./config.guess "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" \
#	&& for crosscompiler in ${GCC_CROSSCOMPILERS}; do \
#		CC=${crosscompiler}-gcc ac_cv_linux_vers=2 ./configure --host=${crosscompiler} --with-pcap=linux \
	&& ./configure \
		&& make \
		&& export LIB_DIR="/usr/local/lib/${crosscompiler}-gcc" VER="$(cat ./VERSION)" MAJOR_VER="$(sed 's/\([0-9][0-9]*\)\..*/\1/' ./VERSION)" \
		&& mkdir -p ${LIB_DIR} \
		&& cp -f libpcap.a libpcap.so.${VER} ${LIB_DIR} \
		&& ln -sf libpcap.so.${VER} /usr/local/lib/libpcap.so.${MAJOR_VER} \
		&& ln -sf libpcap.so.${MAJOR_VER} /usr/local/lib/libpcap.so \
		&& make clean
#; done


# Install Docker
RUN apt-get update \
	&& apt-get install -y docker-ce

COPY build.sh /
ENTRYPOINT ["sh", "/build.sh"]
