FROM cr.loongnix.cn/library/alpine:3.11 as deepflow-server

MAINTAINER zhaixiaojuan@loongson.cn

RUN apk add tzdata

COPY ./server.yaml /etc/
RUN mkdir /etc/mysql
COPY ./controller/db/mysql/migration/rawsql /etc/mysql
COPY ./querier/db_descriptions /etc/db_descriptions/
ARG TARGETARCH 

RUN wget https://github.com/Loongson-Cloud-Community/deepflow/releases/download/loongarch64-v6.1.4/loongarch64-abi1.0-deepflow-server-6.1.4 \
   && mv loongarch64-abi1.0-deepflow-server-6.1.4  /bin/deepflow-server  \
   && chmod +x /bin/deepflow-server


CMD /bin/deepflow-server
