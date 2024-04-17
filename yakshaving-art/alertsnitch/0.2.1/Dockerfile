FROM cr.loongnix.cn/yakshaving-art/multiarch-alpine-base:latest-092a46c7c3ff6a

RUN \
	wget -O /alertsnitch  https://github.com/Loongson-Cloud-Community/alertsnitch/releases/download/v0.2.1-loong64/alertsnitch-0.2.1-loong64-abi1.0 \
	&& chmod +x /alertsnitch

EXPOSE 9567

ENTRYPOINT [ "/alertsnitch" ]
