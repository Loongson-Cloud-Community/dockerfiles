FROM cr.loongnix.cn/kubevirt/passwd:server

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-operator \
	csv-generator \
	/usr/bin/

USER 1001

WORKDIR /home/cdi-operator

ENTRYPOINT ["/usr/bin/cdi-operator"]
