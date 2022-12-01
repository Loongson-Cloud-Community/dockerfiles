FROM cr.loongnix.cn/library/debian:buster-slim

ARG VERSION=1.0.5

COPY predixy-${VERSION}.zip /

RUN apt-get install -y \
		wget \
		gnupg \
	&&\
	wget http://pkg.loongnix.cn/loongnix/pool/main/d/debian-archive-keyring//debian-archive-keyring_2019.1.lnd.2_all.deb &&\
	dpkg -i debian-archive-keyring_2019.1.lnd.2_all.deb &&\
	apt-key add /usr/share/keyrings/debian-archive-buster-loongarch64-stable.gpg &&\
    	rm -f debian-archive-keyring_2019.1.lnd.2_all.deb &&\
	apt-get update &&\
    	apt-get install -y build-essential \
		unzip \
	&&\
    	unzip predixy-${VERSION}.zip &&\
    	cd predixy-${VERSION} &&\
    	make

FROM cr.loongnix.cn/library/debian:buster-slim

ARG VERSION=1.0.5

LABEL maintainer="wangweijie@loongson.cn"

COPY --from=0 /predixy-${VERSION} /predixy

EXPOSE 7617

VOLUME ["/predixy/conf"]

CMD ["/predixy/src/predixy","/predixy/conf/predixy.conf"]
