FROM lcr.loongnix.cn/loongnix/loongnix-server:23.1
ENV GOSU_VERSION 1.17
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN  groupadd -r mongodb && useradd -r -g mongodb mongodb
RUN  mkdir -p /data/db /data/configdb;
RUN dnf install -y  wget gcc python3-devel libffi-devel  cmake  python3-Cython python3-idna  ninja-build  python3-pycparser openssl-devel pip dpkg
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/Loongson-Cloud-Community/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version;\
	gosu nobody true
RUN mkdir /docker-entrypoint-initdb.d
ARG MONGO_PACKAGE=mongodb-org
ARG MONGO_REPO=repo.mongodb.org
ENV MONGO_PACKAGE=${MONGO_PACKAGE} MONGO_REPO=${MONGO_REPO}

ENV MONGO_MAJOR 4.4
ENV MONGO_VERSION 4.4.28
COPY mongo-core-4.4.28-bin  /usr/bin
COPY cryptography-36.0.2-cp311-cp311-linux_loongarch64.whl /
RUN pip install /cryptography-36.0.2-cp311-cp311-linux_loongarch64.whl 

VOLUME /data/db /data/configdb
ENV HOME /data/db

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 27017
CMD ["mongod"]
