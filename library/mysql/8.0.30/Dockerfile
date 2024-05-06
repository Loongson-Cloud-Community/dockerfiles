#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM cr.loongnix.cn/loongson/loongnix-server:8.4
MAINTAINER zhaixiaojuan <zhaixiaojuan@loongson.cn>

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN set -eux; \
	yum makecache; \
	yum install -y bzip2 openssl xz zstd rpm wget; \
# FATAL ERROR: please install the following Perl modules before executing /usr/local/mysql/scripts/mysql_install_db:
# File::Basename
# File::Copy
# Sys::Hostname
# Data::Dumper
#	yum install -y 	perl-interpreter; \
	\
#       yum install -y perl-JSON perl-Memoize perl-Time-HiRes libaio-devel mecab-devel mecab-devel numactl-devel mecab-ipadic mecab-ipadic-EUCJP lz4 perl-CPAN ; \
        yum install -y libaio-devel numactl-devel;

# add gosu for easy step-down from root  && install mysql
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.14
RUN set -eux; \
	yum install -y wget gnupg2; \
	wget -O /usr/local/bin/gosu "https://github.com/Loongson-Cloud-Community/gosu/releases/download/loongson-1.14/gosu-loongarch64"; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true; \
	\
	wget https://github.com/Loongson-Cloud-Community/mysql-rpm/releases/download/v8.0.30/mysql-8.0.30-LA-RPMS-minimal.tar.gz; \
	tar -xf mysql-8.0.30-LA-RPMS-minimal.tar.gz; \
	rpm -ivh --nodeps  mysql-8.0.30-LA-RPMS-minimal/loongarch64/*.rpm; \
	rm -rf mysql-8.0.30-LA-RPMS-minimal.tar.gz mysql-8.0.30-LA-RPMS-minimal;



ENV MYSQL_MAJOR 8.0
ENV MYSQL_VERSION 8.0.30-1loongnixserver8.4

RUN set -eux; \
# make sure users dumping files in "/etc/mysql/conf.d" still works
        ! grep -F '!includedir' /etc/my.cnf; \
        { echo; echo '!includedir /etc/mysql/conf.d/'; } >> /etc/my.cnf; \
        mkdir -p /etc/mysql/conf.d; \
# 5.7 Debian-based images also included "/etc/mysql/mysql.conf.d" so let's include it too
        { echo '!includedir /etc/mysql/mysql.conf.d/'; } >> /etc/my.cnf; \
        mkdir -p /etc/mysql/mysql.conf.d; \
        \
# comment out a few problematic configuration values
        find /etc/my.cnf /etc/mysql/ -name '*.cnf' -print0 \
                | xargs -0 grep -lZE '^(bind-address|log)' \
                | xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/'; \
        \
# ensure these directories exist and have useful permissions
# the rpm package has different opinions on the mode of `/var/run/mysqld`, so this needs to be after install
        mkdir -p /var/lib/mysql /var/run/mysqld; \
        chown mysql:mysql /var/lib/mysql /var/run/mysqld; \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
        chmod 1777 /var/lib/mysql /var/run/mysqld; \
        \
        mkdir /docker-entrypoint-initdb.d; \
        \
        mysqld --version; \
        mysql --version; \
        yum clean packages 


VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306 33060
CMD ["mysqld"]
