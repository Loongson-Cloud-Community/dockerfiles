# SPDX-License-Identifier: GPL-3.0-or-later
# author  : paulfantom

FROM cr.loongnix.cn/library/debian:buster-slim as builder

# One of 'nightly' or 'stable'
ARG RELEASE_CHANNEL=nightly

WORKDIR /app
ADD netdata-loongarch64-v1.33.1.tar.gz /app/

RUN mkdir -p /app/usr/sbin && \
    if [ -f /app/etc/netdata/.environment ]; then \
        sed -i 's|/tmp/build/netdata||g' /app/etc/netdata/.environment; \
    fi

COPY run.sh    /app/usr/sbin/run.sh
COPY health.sh /app/usr/sbin/health.sh
RUN chmod +x /app/usr/sbin/run.sh /app/usr/sbin/health.sh

#####################################################################
FROM cr.loongnix.cn/library/debian:buster-slim as base

ARG OFFICIAL_IMAGE=false
ENV NETDATA_OFFICIAL_IMAGE=$OFFICIAL_IMAGE

# Configure system
RUN apt-get update && apt-get install -y --no-install-recommends \
        libuuid1 \
        zlib1g \
        libmnl0 \
        libuv1 \
        libjson-c3 \
        libssl1.1 \
        liblz4-1 \
        curl \
        adduser \
        && rm -rf /var/lib/apt/lists/*

ARG NETDATA_UID=201
ARG NETDATA_GID=201
ENV DOCKER_GRP netdata
ENV DOCKER_USR netdata

# Copy files over
RUN mkdir -p /opt/src /var/log/netdata && \
    # Link log files to stdout
    ln -sf /dev/stdout /var/log/netdata/access.log && \
    ln -sf /dev/stdout /var/log/netdata/debug.log && \
    ln -sf /dev/stderr /var/log/netdata/error.log && \
    # Add netdata user
    addgroup --gid ${NETDATA_GID} --system "${DOCKER_GRP}" && \
    adduser --system --uid ${NETDATA_UID} --gid ${NETDATA_GID} --home /etc/netdata --shell /usr/sbin/nologin "${DOCKER_USR}"

# Long-term this should leverage BuildKit’s mount option.
COPY --from=builder /app /

# Apply the permissions as described in
# https://docs.netdata.cloud/docs/netdata-security/#netdata-directories
RUN chown -R root:root \
        /etc/netdata \
        /usr/share/netdata \
        /usr/libexec/netdata && \
    chown -R netdata:root \
        /usr/lib/netdata \
        /var/cache/netdata \
        /var/lib/netdata \
        /var/log/netdata && \
    chown -R netdata:netdata /var/lib/netdata/cloud.d && \
    chmod 0700 /var/lib/netdata/cloud.d && \
    chmod 0755 /usr/libexec/netdata/plugins.d/*.plugin && \
    chmod 4755 \
        /usr/libexec/netdata/plugins.d/cgroup-network \
        /usr/libexec/netdata/plugins.d/apps.plugin && \
    if [ -f /usr/libexec/netdata/plugins.d/freeipmi.plugin ]; then \
        chmod 4755 /usr/libexec/netdata/plugins.d/freeipmi.plugin; \
    fi && \
    # Group write permissions due to: https://github.com/netdata/netdata/pull/6543
    find /var/lib/netdata /var/cache/netdata -type d -exec chmod 0770 {} \; && \
    find /var/lib/netdata /var/cache/netdata -type f -exec chmod 0660 {} \;


ENV NETDATA_LISTENER_PORT 19999
EXPOSE $NETDATA_LISTENER_PORT

ENTRYPOINT ["/usr/sbin/run.sh"]

HEALTHCHECK --interval=60s --timeout=10s --retries=3 CMD /usr/sbin/health.sh

ONBUILD ENV NETDATA_OFFICIAL_IMAGE=false
