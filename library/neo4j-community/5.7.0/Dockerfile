FROM cr.loongnix.cn/library/debian:buster
ENV JAVA_HOME=/usr/local/jdk-17.0.6
ENV PATH="${JAVA_HOME}/bin:${PATH}" \
    JAVA_TARBALL=loongson17.4.0-fx-jdk17.0.6_10-linux-loongarch64.tar.gz \
    NEO4J_TARBALL=neo4j-community-5.7.0-SNAPSHOT-unix.tar.gz \
    NEO4J_EDITION=community \
    NEO4J_HOME="/var/lib/neo4j"
ARG NEO4J_URI=https://github.com/Loongson-Cloud-Community/neo4j/releases/download/5.7.0/neo4j-community-5.7.0-SNAPSHOT-unix.tar.gz

RUN addgroup --gid 7474 --system neo4j && adduser --uid 7474 --system --no-create-home --home "${NEO4J_HOME}" --ingroup neo4j neo4j

COPY ./local-package/* /startup/

RUN apt update \
    && apt install -y curl jq tini wget \
    && curl -OL http://ftp.loongnix.cn/Java/openjdk17/${JAVA_TARBALL} \
    && tar -xf ${JAVA_TARBALL} \
    && mv jdk-* /usr/local/ \
    && rm ${JAVA_TARBALL} \
    && curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* "${NEO4J_HOME}" \
    && rm ${NEO4J_TARBALL} \
    && mv "${NEO4J_HOME}"/data /data \
    && mv "${NEO4J_HOME}"/logs /logs \
    && chown -R neo4j:neo4j /data \
    && chmod -R 777 /data \
    && chown -R neo4j:neo4j /logs \
    && chmod -R 777 /logs \
    && chown -R neo4j:neo4j "${NEO4J_HOME}" \
    && chmod -R 777 "${NEO4J_HOME}" \
    && ln -s /data "${NEO4J_HOME}"/data \
    && ln -s /logs "${NEO4J_HOME}"/logs \
    && curl -o /usr/bin/gosu -L https://github.com/Loongson-Cloud-Community/gosu/releases/download/loongson-1.14/gosu-loongarch64 \
    && chmod +x /usr/bin/gosu \
    && apt-get -y purge --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*


ENV PATH "${NEO4J_HOME}"/bin:$PATH

WORKDIR "${NEO4J_HOME}"

VOLUME /data /logs

EXPOSE 7474 7473 7687

ENTRYPOINT ["tini", "-g", "--", "/startup/docker-entrypoint.sh"]
CMD ["neo4j"]
