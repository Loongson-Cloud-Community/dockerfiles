FROM cr.loongnix.cn/ceph/daemon-base:16

LABEL maintainer="znley <shanjiantao@@loongnix.cn>"

# Escape char after immediately after RUN allows comment in first line
RUN \
    echo 'Install packages' && \
      yum install -y --setopt=install_weak_deps=False wget unzip util-linux python3-setuptools udev device-mapper && \
      yum install -y --setopt=install_weak_deps=False --enablerepo=powertools \
          sharutils \
          lsof \
          s3cmd

# Centos 8 doesn't have confd/etcdctl/kubectl packages, so install them from web
RUN \
    echo 'Web install confd etcdctl kubectl' && \
curl -L -o /usr/local/bin/confd \
"https://github.com/Loongson-Cloud-Community/confd/releases/download/v0.16.0/confd-0.16.0-linux-loong64" && \
chmod +x /usr/local/bin/confd && mkdir -p /etc/confd/conf.d && mkdir -p /etc/confd/templates && \
\
curl -L -o /usr/local/bin/etcdctl \
"https://github.com/Loongson-Cloud-Community/etcd/releases/download/v3.5.5/etcdctl" && \
chmod +x /usr/local/bin/etcdctl && \
\
curl -L -o /usr/local/bin/kubectl \
"https://github.com/Loongson-Cloud-Community/kubectl/releases/download/v1.16.2/kubectl" && \
chmod +x /usr/local/bin/kubectl

RUN \
    # Clean container, starting with record of current size (strip / from end)
    INITIAL_SIZE="$(bash -c 'sz="$(du -sm --exclude=/proc /)" ; echo "${sz%*/}"')" && \
    #
    #
    # Perform any final cleanup actions like package manager cleaning, etc.
    yum clean all && \
    # Clean daemon-specific files
    # Let's remove easy stuff
    rm -f /usr/bin/{etcd-tester,etcd-dump-logs} && \
    # Remove etcd since all we need is etcdctl
    rm -f /usr/bin/etcd && \
    # Uncomment below line for more detailed debug info
    # find / -xdev -type f -exec du -c {} \; |sort -n && \
    echo "CLEAN DAEMON DONE!" && \
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
    find  / -xdev -name "*.pyc" -o -name "*.pyo" -exec rm -f {} \; && \
    # ceph-dencoder is only used for debugging, compressing it saves 10MB
    # If needed it will be decompressed
    # TODO: Is ceph-dencoder safe to remove as rook was trying to do?
    # rm -f /usr/bin/ceph-dencoder && \
    if [ -f /usr/bin/ceph-dencoder ]; then gzip -9 /usr/bin/ceph-dencoder; fi && \
    # TODO: What other ceph stuff needs removed/stripped/zipped here?
    # Photoshop files inside a container ?
    rm -f /usr/lib/ceph/mgr/dashboard/static/AdminLTE-*/plugins/datatables/extensions/TableTools/images/psd/* && \
    # Some logfiles are not empty, there is no need to keep them
    find /var/log/ -type f -exec truncate -s 0 {} \; && \
    #
    #
    # Report size savings (strip / from end)
    FINAL_SIZE="$(bash -c 'sz="$(du -sm --exclude=/proc /)" ; echo "${sz%*/}"')" && \
    REMOVED_SIZE=$((INITIAL_SIZE - FINAL_SIZE)) && \
    echo "Cleaning process removed ${REMOVED_SIZE}MB" && \
    echo "Dropped container size from ${INITIAL_SIZE}MB to ${FINAL_SIZE}MB" && \
    #
    # Verify that the packages installed haven't been accidentally cleaned
    rpm -q \
          sharutils \
          lsof \
           \
           \
           \
          s3cmd && echo 'Packages verified successfully'

#======================================================
# Add ceph-container files
#======================================================

# Add s3cfg file
ADD s3cfg /root/.s3cfg

# Add templates for confd
ADD ./confd/templates/* /etc/confd/templates/
ADD ./confd/conf.d/* /etc/confd/conf.d/

# Add bootstrap script, ceph defaults key/values for KV store
ADD *.sh check_zombie_mons.py ./osd_scenarios/* entrypoint.sh.in disabled_scenario /opt/ceph-container/bin/
ADD ceph.defaults /opt/ceph-container/etc/
# ADD *.sh ceph.defaults check_zombie_mons.py ./osd_scenarios/* entrypoint.sh.in disabled_scenario /

# Copye sree web interface for cn
# We use COPY instead of ADD for tarball so that it does not get extracted automatically at build time
COPY Sree-0.2.tar.gz /opt/ceph-container/tmp/sree.tar.gz

# Modify the entrypoint
RUN bash "/opt/ceph-container/bin/generate_entrypoint.sh" && \
  rm -f /opt/ceph-container/bin/generate_entrypoint.sh && \
  bash -n /opt/ceph-container/bin/*.sh

# Execute the entrypoint
WORKDIR /
ENTRYPOINT ["/opt/ceph-container/bin/entrypoint.sh"]
