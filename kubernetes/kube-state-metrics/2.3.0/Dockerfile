FROM cr.loongnix.cn/library/debian:buster

LABEL maintainer="shanjiantao@loongson.cn"

COPY kube-state-metrics /

ENTRYPOINT ["/kube-state-metrics", "--port=8080", "--telemetry-port=8081"]

EXPOSE 8080 8081
