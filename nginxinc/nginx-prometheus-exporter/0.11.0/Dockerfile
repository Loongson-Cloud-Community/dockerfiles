# syntax=docker/dockerfile:1.4
FROM cr.loongnix.cn/library/golang:1.19 as base

ARG VERSION v0.11.0
ARG TARGETARCH loong64

RUN apt update -y && apt upgrade -y && \
	apt install git -y

FROM base as builder

WORKDIR /go/src/github.com/nginxinc/

ENV GOPROXY https://goproxy.cn

RUN git clone -b v0.11.0 --depth=1 https://github.com/nginxinc/nginx-prometheus-exporter.git && \
	cd nginx-prometheus-exporter && \
	go mod download && \
	CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -trimpath -a -ldflags "-s -w -X main.version=${VERSION}" -o nginx-prometheus-exporter .

FROM scratch as container
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/src/github.com/nginxinc/nginx-prometheus-exporter/nginx-prometheus-exporter /usr/bin/
USER 1001:1001
ENTRYPOINT [ "/usr/bin/nginx-prometheus-exporter" ]
