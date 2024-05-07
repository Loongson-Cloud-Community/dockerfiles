FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0 AS builder

ARG DEPENDENCIES="\
            wget"

RUN set -ex \
    && yum install -y ${DEPENDENCIES}

ENV VMAGENT=/vmagent-prod

RUN set -ex \
    && wget -q -O ${VMAGENT} https://github.com/Loongson-Cloud-Community/VictoriaMetrics/releases/download/v1.81.0/vmagent-prod-abi1.0 \
    && chmod +x ${VMAGENT}

FROM cr.loongnix.cn/victoriametrics/base:1.1.3-alpine_3.11-alpine_3.11

EXPOSE 8429

ENTRYPOINT ["/vmagent-prod"]
COPY --from=builder /vmagent-prod ./vmagent-prod
