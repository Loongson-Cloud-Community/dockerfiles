FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

ENV OPERATOR=/usr/local/bin/jaeger-operator \
    USER_UID=1001 \
    USER_NAME=jaeger-operator

RUN INSTALL_PKGS=" \
      openssl \
      " && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all && \
    mkdir /tmp/_working_dir && \
    chmod og+w /tmp/_working_dir

COPY scripts/* /scripts/

# install operator binary
COPY jaeger-operator ${OPERATOR}

ENTRYPOINT ["/usr/local/bin/jaeger-operator"]

USER ${USER_UID}:${USER_UID}
