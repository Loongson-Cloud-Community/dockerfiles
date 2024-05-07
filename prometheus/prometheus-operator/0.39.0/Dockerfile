FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0 AS builder

ARG DEPENDENCIES="\
            wget"

RUN set -ex \
    && yum install -y ${DEPENDENCIES}

ENV OPERATOR=/usr/local/bin/operator

RUN set -ex \
    && wget -q -O ${OPERATOR} https://github.com/Loongson-Cloud-Community/prometheus-operator/releases/download/v0.39.0/prometheus-operator-abi1.0

FROM cr.loongnix.cn/library/busybox:1.30.1

COPY --from=builder  /usr/local/bin/operator /bin/operator

# On busybox 'nobody' has uid `65534'
USER 65534

ENTRYPOINT ["/bin/operator"]
