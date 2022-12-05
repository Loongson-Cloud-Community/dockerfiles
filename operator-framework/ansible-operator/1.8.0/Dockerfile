FROM cr.loongnix.cn/operator-framework/ansible-operator-base:master-1851810cadc2bfeeb106d8fcaad43f3d6d6d817c

LABEL maintainer="wangweijie@loongson.cn"

ENV HOME=/opt/ansible \
    USER_NAME=ansible \
    USER_UID=1001

# Ensure directory permissions are properly set
RUN echo "${USER_NAME}:x:${USER_UID}:0:${USER_NAME} user:${HOME}:/sbin/nologin" >> /etc/passwd \
  && mkdir -p ${HOME}/.ansible/tmp \
  && chown -R ${USER_UID}:0 ${HOME} \
  && chmod -R ug+rwx ${HOME}

WORKDIR ${HOME}
USER ${USER_UID}

COPY ./ansible-operator /usr/local/bin/ansible-operator

ENTRYPOINT ["/tini", "--", "/usr/local/bin/ansible-operator", "run", "--watches-file=./watches.yaml"]
