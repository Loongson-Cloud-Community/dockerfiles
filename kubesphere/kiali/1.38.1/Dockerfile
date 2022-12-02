FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

LABEL maintainer="wangweijie@loongson.cn"

ENV KIALI_HOME=/opt/kiali \
    PATH=$KIALI_HOME:$PATH

WORKDIR $KIALI_HOME

RUN dnf update -y && \
    dnf install -y shadow-utils && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    adduser --uid 1000 kiali

COPY kiali $KIALI_HOME/

ADD console $KIALI_HOME/console/

RUN chown -R kiali:kiali $KIALI_HOME/console && \
    chmod -R g=u $KIALI_HOME/console

USER 1000

ENTRYPOINT ["/opt/kiali/kiali"]
