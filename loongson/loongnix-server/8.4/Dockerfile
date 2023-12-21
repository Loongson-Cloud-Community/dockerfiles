FROM scratch

LABEL maintainer="zhaixiaojuan@loongson.cn"

ARG ROOTFS
ARG BUILD_TIME

ADD ${ROOTFS} /

LABEL images.build-time="${BUILD_TIME}"

CMD ["/bin/bash"]
