FROM cr.loongnix.cn/openanolis/anolisos:8.9
LABEL org.label-schema.schema-version==1.0     org.label-schema.license=GPLv2
CMD ["/bin/bash"]
LABEL maintainer=liujie@loongson.cn
ENV FASTDFS_PATH=/opt/fdfs FASTDFS_BASE_PATH=/var/fdfs PORT= GROUP_NAME= TRACKER_SERVER=
RUN /bin/sh -c "dnf install -y wget zlib zlib-devel pcre pcre-devel gcc gcc-c++ openssl openssl-devel libevent libevent-devel perl unzip net-tools git make"
RUN /bin/sh -c "mkdir -p ${FASTDFS_PATH}/libfastcommon  && mkdir -p ${FASTDFS_PATH}/fastdfs  && mkdir ${FASTDFS_BASE_PATH}" 
WORKDIR /opt/fdfs/libfastcommon
ADD src/libfastcommon ${FASTDFS_PATH}/libfastcommon
RUN ./make.sh  && ./make.sh install  && rm -rf ${FASTDFS_PATH}/libfastcommon
WORKDIR /opt/fdfs/fastdfs
ADD src/fastdfs ${FASTDFS_PATH}/fastdfs
RUN ./make.sh  && ./make.sh install  && rm -rf ${FASTDFS_PATH}/fastdfs
EXPOSE 22122 23000 8080 8888
VOLUME ["/var/fdfs", "/etc/fdfs"]
RUN mkdir -p /tmp/nginx
ADD src/nginx /tmp/nginx/nginx
COPY src/nginx_module /tmp/nginx/nginx_module
WORKDIR /tmp/nginx/nginx
RUN ./auto/configure --prefix=/usr/local/nginx --add-module=/tmp/nginx/nginx_module/src && make && make install
COPY src/nginx/conf/ /etc/fdfs/
RUN ls -al /usr/local/nginx/conf
COPY start1.sh /usr/bin/
RUN chmod 777 /usr/bin/start1.sh
ENTRYPOINT ["/usr/bin/start1.sh"]
CMD ["tracker"]
