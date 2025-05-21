FROM cr.loongnix.cn/library/golang:1.23-buster as builder
ARG MINIO_TAG MC_TAG
ARG RELEASE

ENV GOPATH /go
ENV CGO_ENABLED 0
ENV GOPROXY https://goproxy.cn

COPY ./src /go/src

WORKDIR /go/src/mc
RUN go mod tidy &&  make getdeps && make build && ls

WORKDIR /go/src/minio
RUN go mod tidy && make getdeps && make build && ls

FROM cr.loongnix.cn/library/buildpack-deps:buster-curl

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/src/minio/minio* /usr/bin/
COPY --from=builder /go/src/mc/mc* /usr/bin/


COPY ./src/minio/CREDITS /licenses/CREDITS
COPY ./src/minio/LICENSE /licenses/LICENSE
COPY ./src/minio/dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

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

EXPOSE 9000
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]
