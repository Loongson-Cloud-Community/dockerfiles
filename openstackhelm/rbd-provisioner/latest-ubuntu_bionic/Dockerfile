ARG baseimg
FROM ${baseimg}

RUN set -ex ;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get update ;\
    apt-get install --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        gnupg2 ;\
    apt-get dist-upgrade -y ;\
    apt-get install --no-install-recommends -y ceph-common ;\
    rm -rf /var/lib/apt/lists/* ;\
    rm -rf /usr/share/doc/ ;\
    rm -rf /usr/share/man/ ;\
    rm -rf /usr/share/locale/

COPY ./rbd-provisioner /usr/local/bin/rbd-provisioner
ENTRYPOINT ["/usr/local/bin/rbd-provisioner"]
