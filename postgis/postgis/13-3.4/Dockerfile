#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "make update"! PLEASE DO NOT EDIT IT DIRECTLY.
#
ARG BASE_IMAGE=cr.loongnix.cn/library/postgres:13.13-buster-slim
FROM ${BASE_IMAGE}

LABEL maintainer="zhaixiaojuan@loongson.cn" \
      org.opencontainers.image.description="PostGIS 3.4.0 spatial database extension with PostgreSQL 13 Alpine" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_VERSION 3.4.0
ENV POSTGIS_SHA256 3acdf303adfd58d73543a70e6ebe99af29301262c56cf32220d42caa3efab024
ENV DOCKER_PG_LLVM_DEPS \
                llvm-13-dev \
                clang-13

RUN apt-get install -y libcurl4-gnutls-dev libsqlite3-dev libtiff-dev libcurl3-gnutls libtiff5 \
    && wget https://github.com/Loongson-Cloud-Community/PROJ/releases/download/7.2.0/proj-7.2.0-deb.tar.gz \
    && tar -xf proj-7.2.0-deb.tar.gz \
    && dpkg -i proj-7.2.0-deb/*.deb \
    && rm -rf proj-7.2.0-deb.tar.gz

RUN set -eux \
    && apt-get install -y \
        ca-certificates \
        openssl \
        tar \
    \
    && wget -O postgis.tar.gz "https://github.com/postgis/postgis/archive/${POSTGIS_VERSION}.tar.gz" \
    && echo "${POSTGIS_SHA256} *postgis.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/postgis \
    && tar \
        --extract \
        --file postgis.tar.gz \
        --directory /usr/src/postgis \
        --strip-components 1 \
    && rm postgis.tar.gz \
    \
    && apt-get install -y \
        \
        libgdal-dev \
        libgeos-dev \
#        libproj-dev \
#	libsfcgal-dev \
        libcunit1-dev \
        libjson-c-dev \
        libxml2-dev \
	libxml2-utils \
        libpcre2-dev \
        libprotobuf-c-dev \
        \
        # The upstream variable, '$DOCKER_PG_LLVM_DEPS' contains
        #  the correct versions of 'llvm-dev' and 'clang' for the current version of PostgreSQL.
        # This improvement has been discussed in https://github.com/docker-library/postgres/pull/1077
        $DOCKER_PG_LLVM_DEPS \
        \
        autoconf \
        automake \
        file \
        g++ \
        gcc \
        gettext \
        git \
        libtool \
        make \
        perl \
	docbook-xsl-ns xsltproc \
	protobuf-c-compiler \ 
    \
# build PostGIS - with Link Time Optimization (LTO) enabled
    && cd /usr/src/postgis \
    && gettextize \
    && ./autogen.sh \
    && ./configure \
        --enable-lto \
    && make -j$(nproc) \
    && make install \
    \
# This section is for refreshing the proj data for the regression tests.
# It serves as a workaround for an issue documented at https://trac.osgeo.org/postgis/ticket/5316
# This increases the Docker image size by about 1 MB.
    && projsync --system-directory --file ch_swisstopo_CHENyx06_ETRS \
    && projsync --system-directory --file us_noaa_eshpgn \
    && projsync --system-directory --file us_noaa_prvi \
    && projsync --system-directory --file us_noaa_wmhpgn #\
# This section performs a regression check.
    && mkdir /tempdb \
    && chown -R postgres:postgres /tempdb \
    && su postgres -c 'pg_ctl -D /tempdb init' \
    && su postgres -c 'pg_ctl -D /tempdb -c -l /tmp/logfile -o '-F' start ' \
    && cd regress \
    && make -j$(nproc) check RUNTESTFLAGS=--extension   PGUSER=postgres \
    \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch; --needed for postgis_tiger_geocoder "' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS address_standardizer;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"' \
    && su postgres -c 'psql -t -c "SELECT version();"'              >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "SELECT PostGIS_Full_Version();"' >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "\dx"' >> /_pgis_full_version.txt \
    \
    && su postgres -c 'pg_ctl -D /tempdb --mode=immediate stop' \
    && rm -rf /tempdb \
    && rm -rf /tmp/logfile \
    && rm -rf /tmp/pgis_reg  \
# add .postgis-rundeps
    && apt-get install -y \
        \
#        gdal \
#        geos \
#        sfcgal \
        \
        libjson-c-dev \
        libstdc++-13-dev \
        libpcre2-dev \
        protobuf \
        \
        # ca-certificates: for accessing remote raster files
        #   fix https://github.com/postgis/docker-postgis/issues/307
        ca-certificates \
# clean
    && cd / \
    && rm -rf /usr/src/postgis \
# At the end of the build, we print the collected information
# from the '/_pgis_full_version.txt' file. This is for experimental and internal purposes.
    && cat /_pgis_full_version.txt

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
