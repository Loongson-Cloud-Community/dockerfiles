FROM cr.loongnix.cn/openanolis/anolisos:8.8

RUN set -eu; \
    yum install -y curl unzip ca-certificates openssl libstdc++ ncurses-libs

RUN set -eu; \
    groupadd -r -g 1000 emqx; \
    useradd -r -m -u 1000 -g emqx emqx

ENV EMQX_VERSION=4.2.14

ARG EMQX_URL

RUN set -eu; \
    arch="$(uname -m)"; \
    ID="$(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/\"//g')"; \
    VERSION_ID="$(sed -n '/^VERSION_ID=/p' /etc/os-release | sed -r 's/VERSION_ID=(.*)/\1/g' | sed 's/\"//g')"; \
    pkg="emqx-${EMQX_VERSION}-${ID}${VERSION_ID}-${arch}.zip"; \
    curl -f -O -L ${EMQX_URL}/v${EMQX_VERSION}/$pkg; \
    unzip -q -d /opt $pkg; \
    chgrp -Rf emqx /opt/emqx; \
    chmod -Rf g+w /opt/emqx; \
    chown -Rf emqx /opt/emqx; \
    ln -s /opt/emqx/bin/* /usr/local/bin/; \
    rm -rf $pkg


WORKDIR /opt/emqx

USER emqx

VOLUME ["/opt/emqx/log", "/opt/emqx/data", "/opt/emqx/lib", "/opt/emqx/etc"]

# emqx will occupy these port:
# - 1883 port for MQTT
# - 8081 for mgmt API
# - 8083 for WebSocket/HTTP
# - 8084 for WSS/HTTPS
# - 8883 port for MQTT(SSL)
# - 11883 port for internal MQTT/TCP
# - 18083 for dashboard
# - 4369 epmd (Erlang-distrbution port mapper daemon) listener (deprecated)
# - 4370 default Erlang distrbution port
# - 5369 for gen_rpc port mapping
# - 6369 for distributed node
EXPOSE 1883 8081 8083 8084 8883 11883 18083 4369 4370 5369 6369

COPY docker-entrypoint.sh \
     start.sh \
     /usr/bin/

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["/usr/bin/start.sh"]

