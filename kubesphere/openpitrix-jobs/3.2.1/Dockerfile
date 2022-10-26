FROM cr.loongnix.cn/library/alpine:3.11
RUN apk add --update ca-certificates && update-ca-certificates

WORKDIR /root
COPY import-config.yaml kubesphere/
COPY import-app	/usr/local/bin/
COPY upgrade	/usr/local/bin/

# Disable cache, always download chart package
ARG BUILDDATE
RUN echo "$BUILDDATE"
COPY urls.txt /root
RUN mkdir -p package && cp urls.txt package  && cd /root/package && for pkg in $(cat urls.txt); do wget $pkg; done && rm urls.txt
