FROM cr.loongnix.cn/library/alpine:3.11.11

LABEL maintainer="wangweijie@loongson.cn"

RUN apk update; \
	apk add \
	wget \
	make \
	g++ \
	tcl \
	tcl-dev; \
	cp /usr/lib/tclConfig.sh /usr/lib/tcl8.6/

COPY sqlite-version-3.35.5.tar.gz /

RUN mkdir -p /usr/src/sqlite; \
	tar -xf sqlite-version-3.35.5.tar.gz -C /usr/src/sqlite --strip-components 1; \
	rm -rf sqlite-version-3.35.5.tar.gz; \
	cd /usr/src/sqlite; \
# update config.sub && config.guess
	wget -O ./config.sub "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"; \
	wget -O ./config.guess "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"; \
	./configure --with-tcl=/usr/lib/tcl8.6/; \
	make -j "$(nproc)"; \
	make install; \
	rm -rf /usr/src/sqlite

CMD ["sqlite3"]
