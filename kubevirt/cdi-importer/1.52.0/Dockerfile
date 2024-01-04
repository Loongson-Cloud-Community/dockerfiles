FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

LABEL maintainer="wangweijie@loongson.cn"

COPY cdi-importer \
     cdi-containerimage-server \
     cdi-image-size-detection \
     cdi-source-update-poller \
     /usr/bin/


COPY install_rpm.sh packages.txt /

RUN ./install_rpm.sh; \
    rm -rf install_rpm.sh packages.txt

ADD ca_anchors.tar /

ENTRYPOINT ["/usr/bin/cdi-importer","-alsologtostderr"]
