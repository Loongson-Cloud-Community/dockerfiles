FROM cr.loongnix.cn/library/alpine:3.11

RUN apk --no-cache add \
    ca-certificates

COPY chirpstack /usr/bin/chirpstack
#COPY target/loongarch64-unknown-linux-gnu/release/chirpstack /usr/bin/chirpstack
USER nobody:nogroup
ENTRYPOINT ["/usr/bin/chirpstack"]
