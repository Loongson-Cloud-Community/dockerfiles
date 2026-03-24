FROM cr.loongnix.cn/loongson/loongnix:20

ARG TARGETPLATFORM="linux/loong64"
ARG TARGETARCH="loong64"
ARG ARCH=${TARGETARCH}

ENV DEBIAN_FRONTEND=noninteractive

RUN useradd --system --shell /bin/bash --comment 'GitLab Runner' --create-home --skel /dev/null gitlab-runner

# hadolint ignore=DL3008
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        git git-lfs \
        wget \
        tzdata \
        openssh-client \
        dumb-init \
    && rm -rf /var/lib/apt/lists/*

ARG DOCKER_MACHINE_VERSION

COPY install-deps /tmp/
RUN /tmp/install-deps "${TARGETPLATFORM}" "${DOCKER_MACHINE_VERSION}"
RUN rm -rf /tmp/* /etc/gitlab-runner/.runner_system_id

FROM cr.loongnix.cn/loongson/loongnix:20

COPY --from=0 / /
COPY --chmod=755 ubuntu/entrypoint /

STOPSIGNAL SIGQUIT
VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint"]
CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
