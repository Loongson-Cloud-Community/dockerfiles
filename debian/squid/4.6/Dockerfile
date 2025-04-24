# 使用 Debian Bookworm 作为基础镜像
FROM cr.loongnix.cn/library/debian:buster

ENV TZ=UTC

# 安装 Squid 并清理缓存
RUN set -eux; 	apt-get update; 	DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y; 	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends 		squid ca-certificates tzdata; 	DEBIAN_FRONTEND=noninteractive apt-get remove --purge --auto-remove -y; 	rm -rf /var/lib/apt/lists/*; 	sed -i 's/^#http_access allow localnet$/http_access allow localnet/' /etc/squid/conf.d/debian.conf; 	echo "# Set max_filedescriptors to avoid using system's RLIMIT_NOFILE. See LP: #1978272" > /etc/squid/conf.d/rock.conf; 	echo 'max_filedescriptors 1024' >> /etc/squid/conf.d/rock.conf; 	rm -f /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/private/ssl-cert-snakeoil.key; 	/usr/sbin/squid --version; 	mkdir -p /usr/share/rocks; 	(echo "# os-release" && cat /etc/os-release && echo "# dpkg-query" && dpkg-query -f '${db:Status-Abbrev},${binary:Package},${Version},${source:Package},${Source:Version}\n' -W) > /usr/share/rocks/dpkg.query

EXPOSE 3128

VOLUME ["/var/log/squid", "/var/spool/squid"]


# 初始化缓存目录的启动脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


# 容器启动命令
ENTRYPOINT ["entrypoint.sh"]

CMD ["-f","/etc/squid/squid.conf","-NYC"]
