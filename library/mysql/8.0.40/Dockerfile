# Stage 1: Build MySQL
FROM cr.loongnix.cn/loongson/loongnix-server:8.4 AS builder

# 安装构建所需的依赖
RUN yum install -y wget gnupg2 patch bzip2 openssl xz zstd rpm

# 复制 MySQL 源代码和补丁文件
#COPY mysql-boost-8.0.40.tar.gz /tmp
RUN wget https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-boost-8.0.40.tar.gz -O /tmp/mysql-boost-8.0.40.tar.gz 
COPY no_check_abi.patch /tmp
COPY build_and_install_mysql.sh /tmp
COPY epel-modular.repo /etc/yum.repos.d/
COPY epel.repo /etc/yum.repos.d/

RUN sed -i 's/^enabled=0/enabled=1/' /etc/yum.repos.d/Loongnix-PowerTools.repo;
# 解压并构建 MySQL
RUN cd /tmp && \
    tar -xf mysql-boost-8.0.40.tar.gz && \
    patch -p1 /tmp/mysql-8.0.40/CMakeLists.txt < /tmp/no_check_abi.patch && \
    bash /tmp/build_and_install_mysql.sh && \
    rm -rf /tmp/mysql-boost-8.0.40 /tmp/mysql-8.0.40 /tmp/mysql-boost-8.0.40.tar.gz /tmp/no_check_abi.patch /tmp/build_and_install_mysql.sh

# Stage 2: 运行时镜像
FROM cr.loongnix.cn/loongson/loongnix-server:8.4

# 安装运行时依赖
RUN yum install -y python38-devel libssh wget tar glibc-common && \
    yum clean all && \
    rm -rf /var/cache/yum

# 从构建阶段复制 MySQL 到运行时镜像
COPY --from=builder /usr/local/mysql /usr/local/mysql
#COPY --from=builder /etc/my.cnf /etc/my.cnf
COPY config/conf.d/my.cnf /etc/my.cnf
COPY --from=builder /etc/my.cnf.d /etc/my.cnf.d
COPY --from=builder /etc/logrotate.d/mysql /etc/logrotate.d/mysql

# 从构建阶段拷贝共享库文件
COPY --from=builder /lib64 /lib64
COPY --from=builder /usr/lib64 /usr/lib64

# 安装 MySQL Shell
RUN wget https://github.com/Loongson-Cloud-Community/mysql-shell-rpm/releases/download/v8.0.30/mysql-shell-8.0.30-LA-RPMS-mininal.tar.gz && \
    tar -xf mysql-shell-8.0.30-LA-RPMS-mininal.tar.gz && \
    rpm -ivh --nodeps mysql-shell-8.0.30-LA-RPMS-mininal/loongarch64/*.rpm && \
    rm -rf mysql-shell-8.0.30-LA-RPMS-mininal mysql-shell-8.0.30-LA-RPMS-mininal.tar.gz && \
    wget -O /usr/local/bin/gosu "https://github.com/Loongson-Cloud-Community/gosu/releases/download/loongson-1.14/gosu-loongarch64" && \
    chmod +x /usr/local/bin/gosu && \
    gosu --version && \
    gosu nobody true;

# 设置 MySQL 配置文件
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

RUN set -eux; \
	groupadd --system --gid 1000 mysql; \
	useradd --system --uid 1000 --gid 1000 --home-dir /var/lib/mysql --no-create-home mysql
# 设置环境变量和路径
ENV MYSQL_MAJOR 8.0
ENV MYSQL_VERSION 8.0.40-1loongnixserver8.4
ENV PATH=/usr/local/mysql/sbin:/usr/local/mysql/bin:$PATH

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
        chown mysql:mysql /var/lib/mysql /var/run/mysqld /usr/local/mysql; \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
        chmod 1777 /var/lib/mysql /var/run/mysqld; \
        \
        mkdir /docker-entrypoint-initdb.d; \
        \
        mysqld --version; \
        mysql --version; \
	mysqlsh --version; \
        yum clean packages

# Expose MySQL 服务端口
EXPOSE 3306 33060

# 设置容器启动时的入口命令
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]

# 持久化数据
VOLUME /var/lib/mysql

