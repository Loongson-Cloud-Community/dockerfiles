FROM cr.loongnix.cn/library/golang:1.19 as build

ENV GO111MODULE on
ENV GOPROXY "https://goproxy.cn"

WORKDIR /opt
RUN mkdir etcdkeeper
COPY . /opt/etcdkeeper
WORKDIR /opt/etcdkeeper/src/etcdkeeper

RUN go mod download \
    && go get -u golang.org/x/sys/unix  \
    && go mod tidy \
    && go build -a -ldflags '-extldflags "-static"' -o etcdkeeper.bin main.go


FROM cr.loongnix.cn/library/alpine:3.11

ENV HOST="0.0.0.0"
ENV PORT="8080"

# RUN apk add --no-cache ca-certificates

RUN mkdir /lib64 && ln -s /lib/libc.musl-loongarch64.so.1 /lib64/ld-linux-loongarch64.so.2

WORKDIR /opt/etcdkeeper
COPY --from=build /opt/etcdkeeper/src/etcdkeeper/etcdkeeper.bin .
COPY assets assets

EXPOSE ${PORT}

ENTRYPOINT ./etcdkeeper.bin -h $HOST -p $PORT
