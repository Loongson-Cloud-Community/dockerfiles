FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

LABEL maintainer="wangweijie@loongson.cn"

COPY install_rpm.sh \
     packages.txt \
     /

RUN ./install_rpm.sh; \
    rm -rf install_rpm.sh packages.txt


