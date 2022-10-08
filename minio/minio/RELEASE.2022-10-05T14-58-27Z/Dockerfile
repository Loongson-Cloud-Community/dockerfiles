FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0 

ARG TARGETARCH=loong64

ARG RELEASE=RELEASE.2022-10-05T14-58-27Z

LABEL name="MinIO" \
      vendor="MinIO Inc <dev@min.io>" \
      maintainer="Xuhui Qiang <qiangxuhui@loongson.cn>" \
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
    PATH=/opt/bin:$PATH

COPY dockerscripts/verify-minio.sh /usr/bin/verify-minio.sh
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY CREDITS /licenses/CREDITS
COPY LICENSE /licenses/LICENSE

RUN  	dnf makecache && dnf install wget -y && \
	wget https://github.com/Loongson-Cloud-Community/minio/releases/download/RELEASE.2022-10-05T14-58-27Z/minio-loong64 -O /usr/bin/minio && \
	dnf install curl ca-certificates shadow-utils util-linux -y --nodocs && dnf clean all && chmod +x /usr/bin/minio && chmod +x /usr/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

CMD ["minio"]
