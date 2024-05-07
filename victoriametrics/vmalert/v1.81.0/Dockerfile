FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0 AS builder

ARG DEPENDENCIES="\
            wget"

RUN set -ex \
    && yum install -y ${DEPENDENCIES}

ENV VMALERT=/vmalert-prod

RUN set -ex \
    && wget -q -O ${VMALERT} https://github.com/Loongson-Cloud-Community/VictoriaMetrics/releases/download/v1.81.0/vmalert-prod-v1.81.0-abi1.0 \
    && chmod +x ${VMALERT}

FROM cr.loongnix.cn/victoriametrics/base:1.1.3-alpine_3.11-alpine_3.11

EXPOSE 8880

ENTRYPOINT ["/vmalert-prod"]
COPY --from=builder /vmalert-prod ./vmalert-prod
