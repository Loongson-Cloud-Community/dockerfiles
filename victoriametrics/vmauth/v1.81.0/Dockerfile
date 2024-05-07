FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0 AS builder

ARG DEPENDENCIES="\
            wget"

RUN set -ex \
    && yum install -y ${DEPENDENCIES}

ENV VMAUTH=/vmauth-prod

RUN set -ex \
    && wget -q -O ${VMAUTH} https://github.com/Loongson-Cloud-Community/VictoriaMetrics/releases/download/v1.81.0/vmauth-prod-abi1.0 \
    && chmod +x ${VMAUTH}

FROM cr.loongnix.cn/victoriametrics/base:1.1.3-alpine_3.11-alpine_3.11

EXPOSE 8427

ENTRYPOINT ["/vmauth-prod"]
COPY --from=builder /vmauth-prod /vmauth-prod
