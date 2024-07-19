FROM cr.loongnix.cn/alpine:3.11 as builder

RUN apk update \
    && apk add wget \
    && wget https://github.com/Loongson-Cloud-Community/one-api/releases/download/v0.6.7/one-api -O /one-api \
    && chmod +x /one-api


FROM cr.loongnix.cn/alpine:3.11

RUN apk update \
    && apk upgrade \
    && apk add --no-cache ca-certificates tzdata \
    && update-ca-certificates 2>/dev/null || true

COPY --from=builder /one-api /
EXPOSE 3000
WORKDIR /data
ENTRYPOINT ["/one-api"]
