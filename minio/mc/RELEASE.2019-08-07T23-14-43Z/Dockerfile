FROM cr.loongnix.cn/library/alpine:3.11

COPY mc /usr/bin

RUN apk add \
	--no-cache \
	ca-certificates &&\
	echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

ENTRYPOINT ["mc"]
