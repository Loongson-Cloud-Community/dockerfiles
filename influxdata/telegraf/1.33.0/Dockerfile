FROM cr.loongnix.cn/library/golang:1.23 as builder
ENV GOPROXY https://goproxy.cn
WORKDIR /go/src/telegraf
COPY ./src/telegraf /go/src/telegraf
RUN go mod tidy && make deps
RUN make go-install
FROM cr.loongnix.cn/library/buildpack-deps:buster-curl
COPY --from=builder /go/bin/* /usr/bin/
EXPOSE 8125/udp 8092/udp 8094
ENTRYPOINT ["telegraf"]
