FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-cloner \
	cloner_startup.sh \
	/usr/bin/

RUN chmod 755 /usr/bin/cloner_startup.sh

ENTRYPOINT ["/usr/bin/cloner_startup.sh"]
