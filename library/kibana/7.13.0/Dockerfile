#Please use "make image" to build the docker image
FROM cr.loongnix.cn/library/centos:8.3 as builder

COPY kibana.tar.gz /opt

RUN mkdir /usr/share/kibana
WORKDIR /usr/share/kibana 
RUN tar --strip-components=1 -zxf /opt/kibana.tar.gz \
	&& chmod -R g=u /usr/share/kibana

FROM cr.loongnix.cn/library/centos:8.3

LABEL maintainer="wangweijie@loongson.cn"

EXPOSE 5601

RUN yum update --setopt=tsflags=nodocs -y && \
	yum install --setopt=tsflags=nodocs -y \
		fontconfig \
		freetype \
		shadow-utils \
		nss \
	&& yum clean all

COPY tini-static /bin/tini

RUN chmod +x /bin/tini; \
	mkdir /usr/share/fonts/local

COPY NotoSansCJK-Regular.ttc /usr/share/fonts/local/NotoSansCJK-Regular.ttc
RUN fc-cache -v

COPY --from=builder --chown=1000:0 /usr/share/kibana /usr/share/kibana
WORKDIR /usr/share/kibana
RUN ln -s /usr/share/kibana /opt/kibana

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/kibana/bin:$PATH

# Set some Kibana configuration defaults.
COPY --chown=1000:0 config/kibana.yml /usr/share/kibana/config/kibana.yml

# Add the launcher/wrapper script. It knows how to interpret environment
# variables and translate them to Kibana CLI options.
COPY --chown=1000:0 bin/kibana-docker /usr/local/bin/

# Ensure gid 0 write permissions for OpenShift.
RUN chmod g+ws /usr/share/kibana && \
    find /usr/share/kibana -gid 0 -and -not -perm /g+w -exec chmod g+w {} \;

# Remove the suid bit everywhere to mitigate "Stack Clash"
RUN find / -xdev -perm -4000 -exec chmod u-s {} +

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 kibana && \
    useradd --uid 1000 --gid 1000 -G 0 \
      --home-dir /usr/share/kibana --no-create-home \
      kibana
	
USER kibana

COPY lib/libatomic.so.1 \
	lib/libatomic.so.1.2.0 \
	/lib64/ 

ENTRYPOINT ["/bin/tini", "--"]

CMD ["/usr/local/bin/kibana-docker"]
