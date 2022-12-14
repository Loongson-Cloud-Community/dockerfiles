FROM cr.loongnix.cn/loongson/loongnix-server:8.4

LABEL maintainer="znley <shanjiantao@loongson.cn>"

ENV CEPH_VERSION pacific
ENV CEPH_POINT_RELEASE ""
ENV CEPH_DEVEL false
ENV CEPH_REF pacific
ENV OSD_FLAVOR default

RUN \
    yum update -y && \
yum install -y loongnix-release-ceph-pacific loongnix-release-epel

# Install packages from Github release
RUN \
    yum update -y && \
curl -OL https://github.com/Loongson-Cloud-Community/nfs-ganesha/releases/download/V3.5/nfs-ganesha-loongarch64-rpms.tar.gz && \
tar -xf nfs-ganesha-loongarch64-rpms.tar.gz && yum install -y nfs-ganesha-loongarch64-rpms/* && rm -rf nfs-ganesha-loongarch64-rpms* && \
\
curl -OL https://github.com/Loongson-Cloud-Community/tcmu-runner/releases/download/v1.5.4/tcmu-runner-loongarch64-rpms.tar.gz && \
tar -xf tcmu-runner-loongarch64-rpms.tar.gz && yum install -y tcmu-runner-loongarch64-rpms/* && rm -rf tcmu-runner-loongarch64-rpms* && \
\
curl -OL https://github.com/Loongson-Cloud-Community/ceph-iscsi/releases/download/3.5/ceph-iscsi-noarch-rpms.tar.gz && \
tar -xf ceph-iscsi-noarch-rpms.tar.gz && yum install -y ceph-iscsi-noarch-rpms/* && rm -rf ceph-iscsi-noarch-rpms*

# Install packages from mirror
RUN \
    yum install -y --setopt=install_weak_deps=False \
         ca-certificates \
         e2fsprogs \
         ceph-common-16.2.4  \                                  
         ceph-mon-16.2.4  \
         ceph-osd-16.2.4 \
         ceph-mds-16.2.4 \
         cephfs-mirror-16.2.4 \
         rbd-mirror-16.2.4  \
         ceph-mgr-16.2.4 \
         ceph-mgr-cephadm-16.2.4 \
         ceph-mgr-dashboard-16.2.4 \
         ceph-mgr-diskprediction-local-16.2.4 \
         ceph-mgr-k8sevents-16.2.4 \
         ceph-mgr-rook-16.2.4 \
         python3-saml\
         ceph-grafana-dashboards-16.2.4 \
         kmod \
         lvm2 \
         gdisk \
         smartmontools \
         nvme-cli \
         libstoragemgmt \
         systemd-udev \
         sg3_utils \
         procps-ng \
         hostname \
         ceph-radosgw-16.2.4 libradosstriper1-16.2.4 \
         python3-rtslib \
         attr \
         ceph-fuse-16.2.4 \
         rbd-nbd-16.2.4 \
         ceph-immutable-object-cache-16.2.4

# Clean up TODO

# Tweak some configuration files on the container system
RUN \
    sed -i -e 's/udev_rules = 1/udev_rules = 0/' -e 's/udev_sync = 1/udev_sync = 0/' -e 's/obtain_device_list_from_udev = 1/obtain_device_list_from_udev = 0/' /etc/lvm/lvm.conf && \
grep -sqo "udev_sync = 0" /etc/lvm/lvm.conf && \
grep -sqo "udev_rules = 0" /etc/lvm/lvm.conf && \
grep -sqo "obtain_device_list_from_udev = 0" /etc/lvm/lvm.conf && \
mkdir -p /var/run/ganesha && \
    # Clean common files like /tmp, /var/lib, etc.
    rm -rf \
        /etc/{selinux,systemd,udev} \
        /lib/{lsb,udev} \
        /tmp/* \
        /usr/lib{,64}/{locale,udev,dracut} \
        /usr/share/{doc,info,locale,man} \
        /usr/share/{bash-completion,pkgconfig/bash-completion.pc} \
        /var/log/* \
        /var/tmp/* && \
    find  / -xdev -name "*.pyc" -o -name "*.pyo" -exec rm -f {} \;

# Verify that the packages installed haven't been accidentally cleaned
RUN \ 
    rpm -q \
         ca-certificates \
         e2fsprogs \
         ceph-common  \
         ceph-mon  \
         ceph-osd \
         ceph-mds \
         cephfs-mirror \
         rbd-mirror  \
         ceph-mgr \
         ceph-mgr-cephadm \
         ceph-mgr-dashboard \
         ceph-mgr-diskprediction-local \
         ceph-mgr-k8sevents \
         ceph-mgr-rook \
         python3-saml\
         ceph-grafana-dashboards \
         kmod \
         lvm2 \
         gdisk \
         smartmontools \
         nvme-cli \
         libstoragemgmt \
         systemd-udev \
         sg3_utils \
         procps-ng \
         hostname \
         ceph-radosgw libradosstriper1 \
         python3-rtslib \
         attr \
         ceph-fuse \
         rbd-nbd \
         ceph-immutable-object-cache \
         && echo 'Packages verified successfully'

