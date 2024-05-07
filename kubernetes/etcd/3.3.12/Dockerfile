FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0 AS builder

ARG DEPENDENCIES="\
            wget"

RUN set -ex \
    && yum install -y ${DEPENDENCIES}

ENV ETCD=/usr/local/bin/etcd
ENV ETCDCTL=/usr/local/bin/etcdctl

RUN set -ex \
    && wget -q -O ${ETCD} https://github.com/Loongson-Cloud-Community/etcd/releases/download/v3.3.12/etcd-3.3.12-abi1.0 \
    && chmod +x ${ETCD} \
    && wget -q -O ${ETCDCTL} https://github.com/Loongson-Cloud-Community/etcd/releases/download/v3.3.12/etcdctl-3.3.12-abi1.0 \
    && chmod +x ${ETCDCTL}



FROM cr.loongnix.cn/library/alpine:3.11.11

LABEL maintainer="wangweijie@loongson.cn"

COPY --from=builder /usr/local/bin/etcd /usr/local/bin/etcd
COPY --from=builder /usr/local/bin/etcdctl /usr/local/bin/etcdctl

RUN mkdir -p /var/etcd/ \
    mkdir -p /var/lib/etcd/

RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

EXPOSE 2379 2380

CMD ["/usr/local/bin/etcd"]
