FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

LABEL maintainer="wangweijie@loongson.cn"

COPY .version /

COPY virt_launcher.cil /

COPY nsswitch.conf /etc


RUN groupadd qemu -g 107 &&\
	useradd qemu -u 107 -g 107 &&\
	usermod -s /bin/bash qemu &&\
	mkdir -p /etc/nftables

COPY ipv4-nat.nft /etc/nftables
COPY ipv6-nat.nft /etc/nftables

RUN cd /etc &&\
	dnf update -y &&\
	dnf install -y bzip2 \
		diffutils \
		iptables \
		jansson \
		libaio \
		libbpf \
		libburn \
		libisoburn \
		libisofs \
		libselinux-utils \
		nftables \
		policycoreutils \
		qemu-img \
		rpm-plugin-selinux \
		selinux-policy \
		selinux-policy-targeted \
		xorriso \
	&&\
	cp /usr/sbin/iptables /usr/sbin/iptables-legacy &&\
	chmod 755 nftables &&\
	cd /
	 
COPY virt-handler /usr/bin/
COPY virt-chroot /usr/bin/
COPY container-disk /usr/bin/

ENTRYPOINT ["/usr/bin/virt-handler"] 
