FROM cr.loongnix.cn/library/alpine:3.11 as base
RUN apk --no-cache --update upgrade && apk --no-cache add ca-certificates
RUN mkdir /buildtmp

FROM scratch
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=base /buildtmp /tmp

