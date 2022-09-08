# Please use "make image" to build the docker image
FROM cr.loongnix.cn/library/golang:1.15.6-alpine as build

WORKDIR /go/src/sigs.k8s.io/metrics-server
COPY go.mod .
RUN set -x \
	&& go env -w GOPROXY=http://http://goproxy.loongnix.cn \
	&& go env -w GOSUMDB=off \
	&& go mod download

COPY pkg pkg
COPY cmd cmd
COPY build_file Makefile

ARG ARCH
ARG GIT_COMMIT
ARG GIT_TAG
ARG BUILD_DATE
RUN apk update \
	&& apk add make \
	&& make metrics-server

FROM cr.loongnix.cn/distroless/static
LABEL maintainer="wangweijie@loongson.cn"
COPY --from=build /go/src/sigs.k8s.io/metrics-server/metrics-server /
USER 65534
ENTRYPOINT ["/metrics-server"]
