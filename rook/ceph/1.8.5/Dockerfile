FROM cr.loongnix.cn/ceph/ceph:16

LABEL maintainer="znley <shanjiantao@loongson.cn>"

COPY s5cmd rook toolbox.sh set-ceph-debug-level /usr/local/bin/
COPY ceph-monitoring /etc/ceph-monitoring
COPY rook-external /etc/rook-external/
COPY ceph-csv-templates /etc/ceph-csv-templates
RUN useradd rook -u 2016 # 2016 is the UID of the rook user and also the year of the first commit in the project
USER 2016
ENTRYPOINT ["/usr/local/bin/rook"]
CMD [""]
