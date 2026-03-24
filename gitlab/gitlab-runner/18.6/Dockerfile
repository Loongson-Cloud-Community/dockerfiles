FROM cr.loongnix.cn/gitlab/base-image:runner

ARG TARGETOS="linux"
ARG TARGETARCH="loong64"
ARG SRC_SUFFIX=""

RUN curl -L --fail https://cloud.loongnix.cn/releases/loongarch64abi1/gitlab/gitlab-runner/18.6.3/gitlab-runner -o /usr/bin/gitlab-runner; \
    chmod +x /usr/bin/gitlab-runner

COPY packaging/root/usr/share/gitlab-runner/clear-docker-cache /usr/share/gitlab-runner/clear-docker-cache
