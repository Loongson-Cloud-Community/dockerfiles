FROM cr.loongnix.cn/library/golang:1.19-alpine as builder

RUN apk --no-cache add ca-certificates 

#
# scratch release container
#
FROM scratch as scratch

COPY redis_exporter /redis_exporter
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /etc/nsswitch.conf /etc/nsswitch.conf

# Run as non-root user for secure environments
USER 59000:59000

EXPOSE     9121
ENTRYPOINT [ "/redis_exporter" ]
