FROM cr.loongnix.cn/library/golang:1.21-buster AS builder-mc
ARG TARGETARCH
ARG MC_VERSION=null

WORKDIR /opt
RUN set -ex \
    && git clone -b ${MC_VERSION} --depth=1 https://github.com/minio/mc.git

ARG GOPROXY=https://goproxy.cn,direct
WORKDIR /opt/mc
RUN set -ex \
    && MC_RELEASE="RELEASE" make build \
    && ./mc --version

FROM cr.loongnix.cn/library/golang:1.21-buster AS build
ARG TARGETARCH
ARG MINIO_VERSION=null

WORKDIR /opt
RUN set -ex \
    && git clone -b ${MINIO_VERSION} --depth=1 https://github.com/minio/minio.git

ARG GOPROXY=https://goproxy.cn,direct
WORKDIR /opt/minio
RUN set -ex \
    && MINIO_RELEASE="RELEASE" make build \
    && cp minio minio.${MINIO_VERSION} \
    && echo $(sha256sum minio.${MINIO_VERSION}) > minio.sha256sum \
    && ./minio --version

COPY --from=builder-mc /opt/mc/mc /go/bin/mc

RUN set -ex \
    && cp /opt/minio/minio /go/bin/minio \
    && chmod +x /go/bin/minio \
    && chmod +x /go/bin/mc

FROM cr.loongnix.cn/library/debian:buster-slim

ARG RELEASE

LABEL name="MinIO" \
      vendor="MinIO Inc <dev@min.io>" \
      maintainer="MinIO Inc <dev@min.io>" \
      version="${RELEASE}" \
      release="${RELEASE}" \
      summary="MinIO is a High Performance Object Storage, API compatible with Amazon S3 cloud storage service." \
      description="MinIO object storage is fundamentally different. Designed for performance and the S3 API, it is 100% open-source. MinIO is ideal for large, private cloud environments with stringent security requirements and delivers mission-critical availability across a diverse range of workloads."

ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_ROOT_USER_FILE=access_key \
    MINIO_ROOT_PASSWORD_FILE=secret_key \
    MINIO_KMS_SECRET_KEY_FILE=kms_master_key \
    MINIO_UPDATE_MINISIGN_PUBKEY="RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav" \
    MINIO_CONFIG_ENV_FILE=config.env \
    MC_CONFIG_DIR=/tmp/.mc

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/bin/minio /usr/bin/minio
COPY --from=build /go/bin/mc /usr/bin/mc

COPY --from=build /opt/minio/CREDITS /licenses/CREDITS
COPY --from=build /opt/minio/LICENSE /licenses/LICENSE
COPY --from=build /opt/minio/dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 9000
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]