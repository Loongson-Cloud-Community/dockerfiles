FROM cr.loongnix.cn/library/alpine:3.11

RUN adduser -D -S -h /home/gitlab-runner gitlab-runner

# hadolint ignore=DL3018
RUN apk add --no-cache \
    bash \
    ca-certificates \
    git \
    tzdata \
    openssh-client

# COPY gitlab-runner-linux-* /usr/bin/
COPY install-deps install-gitlab-runner /tmp/

# Install GNU wget for "-nv" flag support
# hadolint ignore=DL3018
RUN apk add --no-cache --virtual .fetch-deps wget curl && \
    /tmp/install-deps && \
    apk del .fetch-deps

COPY entrypoint /
RUN chmod +x /entrypoint

STOPSIGNAL SIGQUIT
VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint"]
CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
