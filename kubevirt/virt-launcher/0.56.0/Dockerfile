FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

LABEL maintainer="wangweijie@loongson.cn"

COPY .version \
     install_rpm.sh \
     packages.txt \
     /

COPY nsswitch.conf /etc/

COPY libvirtd.conf \
        qemu.conf \
        /etc/libvirt/

COPY node-labeller/node-labeller.sh \
        virt-launcher \
        container-disk \
        virt-freezer \
	virt-launcher-monitor \
        virt-probe \
        /usr/bin/
RUN ./install_rpm.sh; \
    rm -rf install_rpm.sh packages.txt

COPY libvirt-8.0-rpm /libvirt-8.0-rpm

RUN dnf install -y /libvirt-8.0-rpm/* &&\
    rm -rf /libvirt-8.0-rpm

RUN setcap CAP_NET_BIND_SERVICE=+eip "/usr/libexec/qemu-kvm" &&\
    ln -s /usr/sbin/iptables /usr/sbin/iptables-legacy &&\
    rm -f /usr/bin/nc &&\
    ln -s /usr/bin/ncat /usr/bin/nc &&\
    ln -s /run /var/run

COPY passwd /etc/

RUN setcap CAP_NET_BIND_SERVICE=+eip "/usr/bin/virt-launcher"

ENTRYPOINT ["/usr/bin/virt-launcher"]
