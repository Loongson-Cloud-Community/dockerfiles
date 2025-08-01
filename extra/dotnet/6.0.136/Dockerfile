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

#RUN wget http://ftp.loongnix.cn/dotnet/8.0.7/8.0.7-1/pkg/dotnet-sdk-8.0.107-linux-loongarch64.tar.xz
RUN wget https://ftp.loongnix.cn/dotnet/6.0.36/6.0.36-1/deb/ -c -r -np -nd -k -L -p -A deb -A md5 \
                -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3" && dpkg -i ./*.deb \
	&& rm -rf *.deb *.md5
 
#RUN mkdir dotnet && tar -xvf dotnet-sdk-8.0.107-linux-loongarch64.tar.xz -C dotnet

#RUN ln -s /root/dotnet/dotnet /usr/bin/dotnet
