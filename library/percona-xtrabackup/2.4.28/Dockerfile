FROM cr.loongnix.cn/loongson/loongnix-server:8.3

LABEL maintainer "yangzewei@loongson.cn"

LABEL descriptions "use centos instead of radhat"

ENV container oci

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["/bin/bash"]

RUN rm -rf /var/log/*

LABEL release=994

COPY ubi8-minimal-container-8.6-994.json /root/buildinfo/content_manifests/ubi8-minimal-container-8.6-994.json


RUN yum -y update && yum -y install glibc-langpack-en

ENV XTRABACKUP_VERSION=2.4.28

ENV PS_VERSION=5.7.41-44.1


RUN yum install -y findutils nmap-ncat glibc openssl-devel libaio \
    libaio-devel automake autoconf libcrypt* wget nmap-ncat\
    bison libtool ncurses-devel libgcrypt-devel libev-devel libcurl-devel zlib-devel \
    zstd vim-common procps-ng-devel; 


RUN wget https://github.com/Loongson-Cloud-Community/percona-xtrabackup/releases/download/percona-xtrabackup-2.4.8/percona-xtrabackup-2.4.28-linux-loongarch64.tar.gz


RUN tar -zxvf percona-xtrabackup-2.4.28-linux-loongarch64.tar.gz -C /usr/local && ln -sn /usr/local/percona-xtrabackup-2.4.28-linux-loongarch64/bin/xtrabackup /usr/bin/xtrabackup


VOLUME [/backup]

CMD ["/usr/bin/xtrabackup"]


