FROM cr.loongnix.cn/library/golang:1.21-buster AS builder-mc
ARG TARGETARCH
ARG MC_VERSION=RELEASE.2024-07-15T17-46-06Z

WORKDIR /opt
RUN set -ex \
    && git clone -b ${MC_VERSION} --depth=1 https://github.com/minio/mc.git

ARG GOPROXY=https://goproxy.cn,direct
WORKDIR /opt/mc
RUN set -ex \
    && MC_RELEASE="RELEASE" make build \
    && ./mc --version

FROM cr.loongnix.cn/library/debian:buster-slim

ARG TARGETARCH
ARG RELEASE

LABEL maintainer="MinIO Inc <dev@min.io>"

COPY --from=builder-mc /opt/mc/mc /usr/bin/mc
COPY --from=builder-mc /opt/mc/CREDITS /licenses/CREDITS
COPY --from=builder-mc /opt/mc/LICENSE /licenses/LICENSE

RUN chmod +x /usr/bin/mc

ENTRYPOINT ["mc"]