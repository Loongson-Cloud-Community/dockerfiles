FROM cr.loongnix.cn/library/alpine:3.11

RUN apk add --no-cache bash ca-certificates tzdata && \
    update-ca-certificates

ENV INFLUXDB_VERSION=1.12.4

COPY influxdb-bins-${INFLUXDB_VERSION}.tar.gz /tmp
RUN mkdir -p /tmp/bins && \
    tar -xzf /tmp/influxdb-bins-1.12.4.tar.gz -C /tmp/bins --strip-components=1 && \
    rm -f /tmp/influxdb-bins-1.12.4.tar.gz && \
    cp /tmp/bins/influxd /usr/bin && \
    cp /tmp/bins/influx /usr/bin && \
    cp /tmp/bins/influx_inspect /usr/bin

COPY influxdb.conf /etc/influxdb/influxdb.conf

RUN addgroup --system --gid 1500 influxdb && \
    adduser --system --uid 1500 --ingroup influxdb --home /var/lib/influxdb --shell /bin/false influxdb && \
    mkdir -p /var/lib/influxdb && \
    mkdir -p /var/log/influxdb && \
    chown influxdb:influxdb /var/lib/influxdb && \
    chown influxdb:influxdb /var/log/influxdb && \
    chmod 0750 /var/lib/influxdb && \
    chmod 0750 /var/log/influxdb

EXPOSE 8086
VOLUME /var/lib/influxdb
COPY entrypoint.sh /entrypoint.sh
COPY init-influxdb.sh /init-influxdb.sh
USER influxdb
ENTRYPOINT ["/entrypoint.sh"]
CMD ["influxd"]
