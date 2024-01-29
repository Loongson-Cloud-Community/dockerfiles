FROM cr.loongnix.cn/library/debian:buster

# see https://github.com/moby/moby/issues/4032#issuecomment-192327844
ARG DEBIAN_FRONTEND=noninteractive


RUN groupdel systemd-journal
# ARG for quick switch to a given ubuntu mirror
RUN groupadd -r clickhouse --gid=101 \
    && useradd -r -g clickhouse --uid=101 --home-dir=/var/lib/clickhouse --shell=/bin/bash clickhouse \
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        gnupg \
        locales \
        wget \
        tzdata \
    && apt-get clean

ARG REPO_CHANNEL="stable"
ARG VERSION="22.3.2"
ARG PACKAGES="clickhouse-client clickhouse-server clickhouse-common-static"

# set non-empty deb_location_url url to create a docker image
# from debs created by CI build, for example:
# docker build . --network host --build-arg version="21.4.1.6282" --build-arg deb_location_url="https://..." -t ...
ARG deb_location_url=""

# set non-empty single_binary_location_url to create docker image
# from a single binary url (useful for non-standard builds - with sanitizers, for arm64).
ARG single_binary_location_url=""

# user/group precreated explicitly with fixed uid/gid on purpose.
# It is especially important for rootless containers: in that case entrypoint
# can't do chown and owners of mounted volumes should be configured externally.
# We do that in advance at the begining of Dockerfile before any packages will be
# installed to prevent picking those uid / gid by some unrelated software.
# The same uid / gid (101) is used both for alpine and ubuntu.

ARG TARGETARCH

RUN arch=${TARGETARCH:-amd64} \
    && if [ -n "${deb_location_url}" ]; then \
        echo "installing from custom url with deb packages: ${deb_location_url}" \
        rm -rf /tmp/clickhouse_debs \
        && mkdir -p /tmp/clickhouse_debs \
	&& wget ${deb_location_url} \
	&& tar -zxf deb.tar.gz -C /tmp/clickhouse_debs --strip-components=2 \
	&& rm /tmp/clickhouse_debs/clickhouse-common-static-dbg_${VERSION}_loongarch64.deb \
	&& rm deb.tar.gz  \
        && dpkg -i /tmp/clickhouse_debs/*.deb ; \
    elif [ -n "${single_binary_location_url}" ]; then \
        echo "installing from single binary url: ${single_binary_location_url}" \
        && rm -rf /tmp/clickhouse_binary \
        && mkdir -p /tmp/clickhouse_binary \
        && wget --progress=bar:force:noscroll "${single_binary_location_url}" -O /tmp/clickhouse_binary/clickhouse \
        && chmod +x /tmp/clickhouse_binary/clickhouse \
        && /tmp/clickhouse_binary/clickhouse install --user "clickhouse" --group "clickhouse" ; \
    else \
        mkdir -p /etc/apt/sources.list.d \
        && apt-key adv --keyserver keyserver.ubuntu.com --recv 8919F6BD2B48D754 \
        && echo ${REPOSITORY} > /etc/apt/sources.list.d/clickhouse.list \
        && echo "installing from repository: ${REPOSITORY}" \
        && apt-get update \
        && apt-get --yes -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade \
        && for package in ${PACKAGES}; do \
            packages="${packages} ${package}=${VERSION}" \
        ; done \
        && apt-get install --allow-unauthenticated --yes --no-install-recommends ${packages} || exit 1 \
    ; fi \
    && clickhouse-local -q 'SELECT * FROM system.build_options' \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
        /tmp/* \
    && mkdir -p /var/lib/clickhouse /var/log/clickhouse-server /etc/clickhouse-server /etc/clickhouse-client \
    && chmod ugo+Xrw -R /var/lib/clickhouse /var/log/clickhouse-server /etc/clickhouse-server /etc/clickhouse-client

# we need to allow "others" access to clickhouse folder, because docker container
# can be started with arbitrary uid (openshift usecase)

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ UTC

RUN mkdir /docker-entrypoint-initdb.d

COPY docker_related_config.xml /etc/clickhouse-server/config.d/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000 8123 9009
VOLUME /var/lib/clickhouse

ENV CLICKHOUSE_CONFIG /etc/clickhouse-server/config.xml

ENTRYPOINT ["/entrypoint.sh"]