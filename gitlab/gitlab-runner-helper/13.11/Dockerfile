FROM cr.loongnix.cn/library/alpine:3.11

# gitlab-runner-helper will try to resolve `sh` from the path. We ensure the PATH is populated by default, as some container runtimes do no longer set a default (e.g. containerd v1.2.8)
ENV PATH="${PATH:-/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin}"

# hadolint ignore=DL3018
RUN apk add --no-cache bash ca-certificates dumb-init git git-lfs miniperl wget\
    && ln -s miniperl /usr/bin/perl

RUN git lfs install --skip-repo

COPY ./helpers/entrypoint /
RUN chmod +x /entrypoint

COPY ./scripts/ /usr/bin/

## 下载gitlab-runner-helper
RUN wget -nv "https://github.com/Loongson-Cloud-Community/gitlab-runner/releases/download/v13.11.0/gitlab-runner-helper.loongarch64" -O /usr/bin/gitlab-runner-helper \
&& chmod +x /usr/bin/gitlab-runner-helper \
&& gitlab-runner-helper -v

RUN echo 'hosts: files dns' >> /etc/nsswitch.conf

# NOTE: The ENTRYPOINT metadata is not preserved on export, so we need to reapply this metadata on import.
# See https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/2058#note_388341301
ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint"]
CMD ["sh"]
