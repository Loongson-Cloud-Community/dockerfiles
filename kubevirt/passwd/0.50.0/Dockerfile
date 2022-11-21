FROM cr.loongnix.cn/library/debian:buster-slim

LABEL maintainer="wangweijie@loongson.cn"

RUN groupadd nonroot-user -g 1001 &&\
	useradd -m nonroot-user -u 1001 -g 1001 &&\
	usermod -s /bin/bash nonroot-user

ENV architecture=loongarch64

USER 1001

CMD ["/bin/bash"]
