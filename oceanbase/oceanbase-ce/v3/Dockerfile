FROM cr.loongnix.cn/openanolis/anolisos:8.9

ARG VERSION

WORKDIR /root

RUN mkdir -p pkgs
COPY oceanbase-all-in-one/rpms/* /root/pkgs 
RUN yum install -y squashfs-tools && yum clean all
RUN yum install -y yum-utils && \
    yum clean all

ADD build/demo.yaml /root/
ADD build/convert-sparse-files.sh /root/
# download and clone all the required packages
RUN yum install -y /root/pkgs/*.rpm
RUN obd mirror clone /root/pkgs/*.rpm
RUN obd env set IO_DEFAULT_CONFIRM 1
RUN obd mirror disable remote
RUN obd cluster deploy demo -c /root/demo.yaml
RUN obd cluster start demo -v && obd cluster tenant create demo -n test -o express_oltp -v && timeout=300; while [ $timeout -gt 0 ] && [ ! -s /root/demo/etc/observer.config.bin ]; do echo "config still not persisted"; sleep 1; timeout=$((timeout - 1)); done

RUN obd cluster stop demo
RUN sed -i "s/\s\+hash:.*//g" /root/.obd/cluster/demo/.data

ADD build/start-pre.sh /root/
ADD build/handle-clog.sh /root/

ENTRYPOINT ["/root/start-pre.sh"]
