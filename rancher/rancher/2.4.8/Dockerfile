FROM cr.loongnix.cn/library/debian:buster
RUN apt-get update && apt-get install -y git curl ca-certificates unzip xz-utils && \
    useradd rancher && \
    mkdir -p /var/lib/rancher/etcd /var/lib/cattle /opt/jail /opt/drivers/management-state/bin && \
    chown -R rancher /var/lib/rancher /var/lib/cattle /usr/local/bin
RUN mkdir /root/.kube && \
    ln -s /etc/rancher/k3s/k3s.yaml /root/.kube/k3s.yaml  && \
    ln -s /etc/rancher/k3s/k3s.yaml /root/.kube/config && \
    ln -s /usr/bin/rancher /usr/bin/reset-password && \
    ln -s /usr/bin/rancher /usr/bin/ensure-default-admin && \
    rm -f /bin/sh && ln -s /bin/bash /bin/sh
WORKDIR /var/lib/rancher

ARG ARCH=loong64
ARG IMAGE_REPO=rancher
ARG SYSTEM_CHART_DEFAULT_BRANCH=release-v2.4
ARG DASHBOARD_BRANCH=release-2.4
# kontainer-driver-metadata branch to be set for specific branch, logic at rancher/rancher/pkg/settings/setting.go
ARG RANCHER_METADATA_BRANCH=release-v2.4

ENV CATTLE_SYSTEM_CHART_DEFAULT_BRANCH=$SYSTEM_CHART_DEFAULT_BRANCH
ENV CATTLE_HELM_VERSION=v2.16.8-rancher1
ENV CATTLE_K3S_VERSION=v1.17.2+k3s1
ENV CATTLE_MACHINE_VERSION=v0.15.0-rancher45
ENV CATTLE_ETCD_VERSION=v3.4.3
ENV CATTLE_CHANNELSERVER_VERSION=v0.3.0
ENV LOGLEVEL_VERSION=v0.1.5
ENV TINI_VERSION=v0.18.0
ENV TELEMETRY_VERSION=v0.5.12
ENV KUBECTL_VERSION=v1.17.6
ENV DOCKER_MACHINE_LINODE_VERSION=v0.1.8
ENV LINODE_UI_DRIVER_VERSION=v0.3.0
ENV RANCHER_METADATA_BRANCH=${RANCHER_METADATA_BRANCH}
ENV CATTLE_DASHBOARD_INDEX=https://releases.rancher.com/dashboard/${DASHBOARD_BRANCH}/index.html
ENV HELM_VERSION=v3.2.0
ENV KUSTOMIZE_VERSION=v3.5.4

RUN mkdir -p /var/lib/rancher-data/local-catalogs/system-library && \
    mkdir -p /var/lib/rancher-data/local-catalogs/library && \
    mkdir -p /var/lib/rancher-data/local-catalogs/helm3-library && \
    git clone -b $CATTLE_SYSTEM_CHART_DEFAULT_BRANCH --single-branch https://github.com/rancher/system-charts /var/lib/rancher-data/local-catalogs/system-library && \
    git clone -b master --single-branch https://github.com/rancher/charts /var/lib/rancher-data/local-catalogs/library && \
    git clone -b master --single-branch https://github.com/rancher/helm3-charts /var/lib/rancher-data/local-catalogs/helm3-library


RUN curl -sLf https://github.com/Loongson-Cloud-Community/rancher_machine/releases/download/v0.15.0-rancher45/rancher-machine-loong64.tar.gz | tar xvzf - -C /usr/bin && \
    curl -sLf https://github.com/Loongson-Cloud-Community/rancher_loglevel/releases/download/v0.1.5/loglevel-loong64-v0.1.5.tar.gz | tar xvzf - -C /usr/bin && \
    curl -LO https://github.com/Loongson-Cloud-Community/docker-machine-driver-linode/releases/download/v0.1.8/docker-machine-driver-linode_linux-$ARCH.zip && \
    unzip docker-machine-driver-linode_linux-$ARCH.zip -d /opt/drivers/management-state/bin && \
    rm docker-machine-driver-linode_linux-$ARCH.zip

ENV TINI_URL_amd64=https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
    TINI_URL_arm64=https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-arm64 \
    TINI_URL_loong64=https://github.com/Loongson-Cloud-Community/tini/releases/download/${TINI_VERSION}/tini-loong64 \
    TINI_URL=TINI_URL_${ARCH}

ENV HELM_URL_V2_amd64=https://github.com/rancher/helm/releases/download/${CATTLE_HELM_VERSION}/rancher-helm \
    HELM_URL_V2_arm64=https://github.com/rancher/helm/releases/download/${CATTLE_HELM_VERSION}/rancher-helm-arm64 \
    HELM_URL_V2_loong64=https://github.com/Loongson-Cloud-Community/rancher_helm/releases/download/${CATTLE_HELM_VERSION}/rancher-helm-loong64 \
    HELM_URL_V2=HELM_URL_V2_${ARCH} \
    HELM_URL_V3=https://github.com/Loongson-Cloud-Community/helm/releases/download/v3.2.0/helm-v3.2.0-linux-loong64.tar.gz \
    TILLER_URL_amd64=https://github.com/rancher/helm/releases/download/${CATTLE_HELM_VERSION}/rancher-tiller \
    TILLER_URL_arm64=https://github.com/rancher/helm/releases/download/${CATTLE_HELM_VERSION}/rancher-tiller-arm64 \
    TILLER_URL_loong64=https://github.com/Loongson-Cloud-Community/rancher_helm/releases/download/${CATTLE_HELM_VERSION}/rancher-tiller-loong64 \
    TILLER_URL=TILLER_URL_${ARCH} \
    K3S_URL_amd64=https://github.com/rancher/k3s/releases/download/${CATTLE_K3S_VERSION}/k3s \
    K3S_URL_arm64=https://github.com/rancher/k3s/releases/download/${CATTLE_K3S_VERSION}/k3s-arm64 \
    K3S_URL_loong64=https://github.com/Loongson-Cloud-Community/k3s/releases/download/v1.21.0%2Bk3s1/k3s-loong64 \
    K3S_URL=K3S_URL_${ARCH} \
    CHANNELSERVER_URL_amd64=https://github.com/rancher/channelserver/releases/download/${CATTLE_CHANNELSERVER_VERSION}/channelserver-amd64 \
    CHANNELSERVER_URL_arm64=https://github.com/rancher/channelserver/releases/download/${CATTLE_CHANNELSERVER_VERSION}/channelserver-arm64 \
    CHANNELSERVER_URL_loong64=https://github.com/Loongson-Cloud-Community/rancher_channelserver/releases/download/v0.3.0/channelserver-loong64 \
    CHANNELSERVER_URL=CHANNELSERVER_URL_${ARCH} \
    ETCD_URL_amd64=https://github.com/etcd-io/etcd/releases/download/${CATTLE_ETCD_VERSION}/etcd-${CATTLE_ETCD_VERSION}-linux-amd64.tar.gz \
    ETCD_URL_arm64=https://github.com/etcd-io/etcd/releases/download/${CATTLE_ETCD_VERSION}/etcd-${CATTLE_ETCD_VERSION}-linux-arm64.tar.gz \
    ETCD_URL_loong64=https://github.com/Loongson-Cloud-Community/etcd/releases/download/${CATTLE_ETCD_VERSION}/etcd-${CATTLE_ETCD_VERSION}-linux-loong64.tar.gz \
    ETCD_URL=ETCD_URL_${ARCH} \
    KUSTOMIZE_URL_amd64=https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
    KUSTOMIZE_URL_arm64=https://github.com/brendarearden/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_arm64.tar.gz \
    KUSTOMIZE_URL_loong64=https://github.com/Loongson-Cloud-Community/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_loong64.tar.gz \
    KUSTOMIZE_URL=KUSTOMIZE_URL_${ARCH}

RUN if [ "${ARCH}" == "arm64" ]; then \
    curl -sLf ${!KUSTOMIZE_URL} | tar xvzf - --strip-components=1 -C /usr/bin; else \
    curl -sOL ${!KUSTOMIZE_URL} && \
    sleep 1 && \
    tar xzf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz -C /usr/bin && \
    rm kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz; \
    fi

# set up helm 2
RUN curl -sLf ${!HELM_URL_V2} > /usr/bin/rancher-helm && \
    curl -sLf ${!TILLER_URL} > /usr/bin/rancher-tiller && \
    ln -s /usr/bin/rancher-helm /usr/bin/helm && \
    ln -s /usr/bin/rancher-tiller /usr/bin/tiller && \
    chmod +x /usr/bin/rancher-helm /usr/bin/rancher-tiller

# set up helm 3
RUN curl -sLf ${HELM_URL_V3} | tar xvzf - --strip-components=1 -C /usr/bin && \
    mv /usr/bin/helm /usr/bin/helm_v3 && \
    chmod +x /usr/bin/kustomize

RUN curl -sLf ${!TINI_URL} > /usr/bin/tini && \
    curl -sLf ${!CHANNELSERVER_URL} > /usr/bin/channelserver && \
    curl -sLf ${!K3S_URL} > /usr/bin/k3s && \
    curl -sfL ${!ETCD_URL} | tar xvzf - --strip-components=1 -C /usr/bin/ etcd-${CATTLE_ETCD_VERSION}-linux-${ARCH}/etcd etcd-${CATTLE_ETCD_VERSION}-linux-${ARCH}/etcdctl && \
    curl -sLf https://github.com/Loongson-Cloud-Community/rancher_telemetry/releases/download/v0.5.12/telemetry-loong64 > /usr/bin/telemetry && \
    curl -sLf https://github.com/Loongson-Cloud-Community/kubernetes/releases/download/v1.17.6/kubelet > /usr/bin/kubectl && \
    chmod +x /usr/bin/tini /usr/bin/telemetry /usr/bin/k3s /usr/bin/kubectl /usr/bin/channelserver && \
    mkdir -p /var/lib/rancher-data/driver-metadata

ENV CATTLE_UI_PATH /usr/share/rancher/ui
ENV CATTLE_UI_VERSION 2.4.34
ENV CATTLE_CLI_VERSION v2.4.6

# Please update the api-ui-version in pkg/settings/settings.go when updating the version here.
ENV CATTLE_API_UI_VERSION 1.1.9

RUN mkdir -p /var/log/auditlog
ENV AUDIT_LOG_PATH /var/log/auditlog/rancher-api-audit.log
ENV AUDIT_LOG_MAXAGE 10
ENV AUDIT_LOG_MAXBACKUP 10
ENV AUDIT_LOG_MAXSIZE 100
ENV AUDIT_LEVEL 0
VOLUME /var/log/auditlog

RUN mkdir -p /usr/share/rancher/ui && \
    cd /usr/share/rancher/ui && \
    curl -sL https://releases.rancher.com/ui/${CATTLE_UI_VERSION}.tar.gz | tar xvzf - --strip-components=1 && \
    mkdir -p assets/rancher-ui-driver-linode && \
    cd assets/rancher-ui-driver-linode && \
    curl -O https://linode.github.io/rancher-ui-driver-linode/releases/${LINODE_UI_DRIVER_VERSION}/component.js && \
    curl -O https://linode.github.io/rancher-ui-driver-linode/releases/${LINODE_UI_DRIVER_VERSION}/component.css && \
    curl -O https://linode.github.io/rancher-ui-driver-linode/releases/${LINODE_UI_DRIVER_VERSION}/linode.svg && \
    mkdir -p /usr/share/rancher/ui/api-ui && \
    cd /usr/share/rancher/ui/api-ui && \
    curl -sL https://releases.rancher.com/api-ui/${CATTLE_API_UI_VERSION}.tar.gz | tar xvzf - --strip-components=1 && \
    cd /var/lib/rancher

ENV CATTLE_CLI_URL_DARWIN  https://releases.rancher.com/cli2/${CATTLE_CLI_VERSION}/rancher-darwin-amd64-${CATTLE_CLI_VERSION}.tar.gz
ENV CATTLE_CLI_URL_LINUX   https://github.com/Loongson-Cloud-Community/rancher_cli/releases/download/v2.4.6/rancher-linux-loong64-v2.4.6.tar.gz
ENV CATTLE_CLI_URL_WINDOWS https://releases.rancher.com/cli2/${CATTLE_CLI_VERSION}/rancher-windows-386-${CATTLE_CLI_VERSION}.zip

ARG VERSION=dev
ENV CATTLE_SERVER_VERSION ${VERSION}
COPY entrypoint.sh rancher /usr/bin/
COPY kustomize.sh /usr/bin/
COPY jailer.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/kustomize.sh

COPY data.json /var/lib/rancher-data/driver-metadata/

ENV CATTLE_AGENT_IMAGE ${IMAGE_REPO}/rancher-agent:${VERSION}
ENV CATTLE_SERVER_IMAGE ${IMAGE_REPO}/rancher
ENV ETCD_UNSUPPORTED_ARCH=${ARCH}
ENV ETCDCTL_API=3

ENV SSL_CERT_DIR /etc/rancher/ssl
VOLUME /var/lib/rancher

ENTRYPOINT ["entrypoint.sh"]
