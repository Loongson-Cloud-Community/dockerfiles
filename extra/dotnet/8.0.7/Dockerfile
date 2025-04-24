FROM cr.loongnix.cn/library/debian:buster
WORKDIR /root
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        wget \
        tzdata \
        openssh-client \
        xz-utils \
        libicu67

RUN wget http://ftp.loongnix.cn/dotnet/8.0.7/8.0.7-1/pkg/dotnet-sdk-8.0.107-linux-loongarch64.tar.xz

RUN mkdir dotnet && tar -xvf dotnet-sdk-8.0.107-linux-loongarch64.tar.xz -C dotnet

RUN ln -s /root/dotnet/dotnet /usr/bin/dotnet
