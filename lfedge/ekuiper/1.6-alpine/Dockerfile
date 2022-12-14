FROM cr.loongnix.cn/library/alpine:3.11

LABEL maintainer="wangweijie@loongson.cn"

# Set environment vars
ENV MAINTAINER="emqx.io" \
    KUIPER_HOME="/kuiper" \
    KUIPER__BASIC__CONSOLELOG=true

# These vars are not persisted in the final image layer
ARG KUIPER_USER="kuiper"
ARG KUIPER_USER_ID="1001"

# (root) Add packages and "kuiper" user
RUN apk add sed libzmq

WORKDIR ${KUIPER_HOME}

# Set appropriate ownership to allow binary full access to KUIPER_HOME dir
RUN adduser -DH -s /sbin/nologin -u ${KUIPER_USER_ID} ${KUIPER_USER} && \
    chown -Rh ${KUIPER_USER}:${KUIPER_USER} ${KUIPER_HOME} && \
    mkdir -p /usr/local/taos && \
    chown -Rh ${KUIPER_USER}:${KUIPER_USER} /usr/local/taos

# Run the kuiper process under the kuiper user
USER ${KUIPER_USER}

COPY --chown=${KUIPER_USER}:${KUIPER_USER} docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY --chown=${KUIPER_USER}:${KUIPER_USER} kuiper-* /kuiper/

VOLUME ["${KUIPER_HOME}/etc", "${KUIPER_HOME}/data", "${KUIPER_HOME}/plugins", "${KUIPER_HOME}/log"]
EXPOSE 9081 20498

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["./bin/kuiperd"]
