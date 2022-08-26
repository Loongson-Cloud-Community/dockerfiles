FROM cr.loongnix.cn/loongson/loongnix:20

LABEL maintainer wangweijie@loongson.cn

ARG REGISTRY=http://registry.npm.taobao.org

RUN \
	set -x \
	&& apt-get update \
	&& apt-get install -y \
	python \
	python3 \
	net-tools \
	build-essential \
	python3-pip \
	cmake \
	make \
	gcc \
	g++ \
	nodejs \
	npm \
	&& pip3 install ninja 

RUN \
	npm config set registry ${REGISTRY} \
	&& npm install yarn -g

WORKDIR /service

COPY package.json .

RUN yarn install

COPY server.js .

COPY config.js .

COPY lib lib

COPY certs certs

CMD ["node","/service/server.js"]


