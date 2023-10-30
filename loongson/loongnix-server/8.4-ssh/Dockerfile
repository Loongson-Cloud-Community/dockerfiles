From cr.loongnix.cn/loongson/loongnix-server:8.4.0
MAINTAINER ligang@loongson.cn

RUN yum install systemd -y
RUN yum install openssh-server openssh-clients openssh vim-minimal sudo net-tools bridge-utils iputils iproute lsof telnet passwd vim initscripts -y
RUN mkdir /var/run/sshd
#修改root用户密码
RUN echo "root:Loongson@123" | chpasswd

RUN echo "alias ll='ls -l'" >> /usr/bin/ll
#RUN echo "loongson:Loongson@123" | chpasswd

#创建非对称秘钥
#RUN rm -rf /etc/ssh/ssh_host_rsa_key
#RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
#生成 ssh-key
RUN ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key

#创建ssh工作目录并设置权限
#RUN mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i== \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;
#创建卷，便于挂载到host
#VOLUME ["/sys/fs/cgroup"]
#RUN service ssh start
ADD run.sh /run.sh
RUN chmod 777 /run.sh

#暴露端口
EXPOSE 22
# 镜像运行时启动ssh
CMD ["/run.sh"]

