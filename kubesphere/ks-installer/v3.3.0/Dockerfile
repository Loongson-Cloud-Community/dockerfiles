FROM cr.loongnix.cn/library/python3:alpine

MAINTAINER Xuhui Qiang <qiangxuhui@loongson.cn>

RUN apk --no-cache add jq bash curl unzip openssl && \
    apk --no-cache add gcc libffi-dev openssl-dev musl-dev && \
    export CRYPTOGRAPHY_DONT_BUILD_RUST=1 && \
    pip3 install cryptography -i http://pypi.loongnix.cn/loongson/pypi --trusted-host pypi.loongnix.cn && \
    pip install --no-cache-dir ansible_runner==2.0.1 ansible==2.9.23 kubernetes -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com && \ 
    apk del gcc libffi-dev openssl-dev musl-dev && \
    wget https://github.com/Loongson-Cloud-Community/helm/releases/download/v3.9.0/helm-loong64-3.9.0-static -O /bin/helm && \
    chmod +x /bin/helm && \
    wget https://github.com/Loongson-Cloud-Community/shell-operator/releases/download/v1.0.0-beta.5/shell-operator-loong64-v1.0.0-beta.5 -O /shell-operator && \
    chmod +x /shell-operator && \
    wget https://github.com/Loongson-Cloud-Community/kubernetes/releases/download/v1.19.0/kubectl-loong64 -O /bin/kubectl && \
    chmod +x /bin/kubectl && \
    ln -s /bin/kubectl /usr/local/bin/kubectl && \
    ln -s /bin/helm /usr/local/bin/helm && \
    mkdir -p /hooks/kubesphere /kubesphere/installer/roles /kubesphere/results/env /kubesphere/playbooks /kubesphere/config &&\
    adduser -D -g kubesphere -u 1002 kubesphere

ADD controller/* /hooks/kubesphere/

RUN chown -R kubesphere:kubesphere /shell-operator && \
    chown -R kubesphere:kubesphere /hooks && \
    chown -R kubesphere:kubesphere /kubesphere && \
    chmod +x -R /hooks/kubesphere

USER kubesphere

ENV SHELL_OPERATOR_WORKING_DIR /hooks
ENV ANSIBLE_ROLES_PATH /kubesphere/installer/roles

WORKDIR /kubesphere

ADD roles /kubesphere/installer/roles

ADD env /kubesphere/results/env

ADD playbooks /kubesphere/playbooks

ENTRYPOINT ["/shell-operator"]

CMD ["start"]
