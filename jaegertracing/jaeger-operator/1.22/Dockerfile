FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0 AS builder

ARG DEPENDENCIES="\
            wget"

RUN set -ex \
    && yum install -y ${DEPENDENCIES}

ENV OPERATOR=/usr/local/bin/jaeger-operator

RUN set -ex \
    && wget -q -O ${OPERATOR} https://github.com/Loongson-Cloud-Community/jaeger-operator/releases/download/release%2Fv1.22.0/jaeger-operator \
    && chmod +x ${OPERATOR}


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
COPY --from=builder ${OPERATOR} ${OPERATOR}

ENTRYPOINT ["/usr/local/bin/jaeger-operator"]

USER ${USER_UID}:${USER_UID}
