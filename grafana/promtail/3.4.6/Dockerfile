ARG GO_IMG=golang:1.23-bookworm
ARG BASE_IMG=public.ecr.aws/ubuntu/ubuntu:noble

FROM ${GO_IMG} as build
ARG IMAGE_TAG

COPY . /src/loki
WORKDIR /src/loki
RUN apt-get update && apt-get install -qy libsystemd-dev
RUN make clean && make BUILD_IN_CONTAINER=false PROMTAIL_JOURNAL_ENABLED=true IMAGE_TAG=${IMAGE_TAG} promtail

# Promtail requires debian or ubuntu as the base image to support systemd journal reading
FROM ${BASE_IMG}
# tzdata required for the timestamp stage to work
# Install dependencies needed at runtime.
RUN  apt-get update \
 &&  apt-get install -qy libsystemd-dev tzdata ca-certificates \
 &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY --from=build /src/loki/clients/cmd/promtail/promtail /usr/bin/promtail
COPY clients/cmd/promtail/promtail-docker-config.yaml /etc/promtail/config.yml
ENTRYPOINT ["/usr/bin/promtail"]
CMD ["-config.file=/etc/promtail/config.yml"]
