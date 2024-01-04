FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

LABEL maintainer="wangweijie@loongson.cn"

COPY .version \
     virt_launcher.cil \
     install_rpm.sh \
     packages.txt \
     /

COPY nsswitch.conf /etc/

RUN groupadd qemu -g 107 &&\
        useradd qemu -u 107 -g 107 &&\
        usermod -s /bin/bash qemu &&\
        mkdir -p /etc/nftables

COPY ipv4-nat.nft \
     ipv6-nat.nft \
     /etc/nftables/

RUN ./install_rpm.sh ;\
    rm -rf install_rpm.sh packages.txt ;\
    cp /usr/sbin/iptables /usr/sbin/iptables-legacy; \
    chmod 755 /etc/nftables

COPY virt-handler \
     virt-chroot \
     container-disk \
     /usr/bin/

ENTRYPOINT ["/usr/bin/virt-handler"]

