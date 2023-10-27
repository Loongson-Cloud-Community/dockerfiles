FROM scratch

LABEL maintainer="ligang@loongson.cn"

ARG ROOTFS
ARG BUILD_TIME

ADD ${ROOTFS} /

LABEL images.build-time="${BUILD_TIME}"
RUN apt update || apt update && apt install init -y
RUN apt update || apt update && apt install openssh-server sudo net-tools bridge-utils iputils-ping iproute2 lsof telnet passwd vim initscripts -y
RUN mkdir /var/run/sshd
#修改root用户密码
RUN echo "root:Loongson@123" | chpasswd
#设置不使用ssh服务端的pam模块
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
#关闭pam.d的ssh会话模块
RUN sed -i '/^session\s\+required\s\+pam_loginuid.so/s/^ /#/' /etc/pam.d/sshd
#开启root登录
RUN echo "PermitRootLogin yes #允许root登录" >> /etc/ssh/sshd_config

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i== \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;

ADD run.sh /run.sh
RUN chmod 777 /run.sh

#暴露端口
EXPOSE 22

# 镜像运行时启动ssh
CMD ["/run.sh"]
