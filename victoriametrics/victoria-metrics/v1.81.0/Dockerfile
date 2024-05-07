FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0 AS builder

ARG DEPENDENCIES="\
            wget"

RUN set -ex \
    && yum install -y ${DEPENDENCIES}

ENV METRICS=/victoria-metrics-prod

RUN set -ex \
    && wget -q -O ${METRICS} https://github.com/Loongson-Cloud-Community/VictoriaMetrics/releases/download/v1.81.0/victoria-metrics-prod-abi1.0 \
    && chmod +x ${METRICS}

FROM cr.loongnix.cn/victoriametrics/base:1.1.3-alpine_3.11-alpine_3.11

EXPOSE 8428

ENTRYPOINT ["/victoria-metrics-prod"]
COPY --from=builder /victoria-metrics-prod ./victoria-metrics-prod
