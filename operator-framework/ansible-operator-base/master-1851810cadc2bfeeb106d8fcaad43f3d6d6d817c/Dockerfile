# This Dockerfile defines the base image for the ansible-operator image.
# It is built with dependencies that take a while to download, thus speeding
# up ansible deploy jobs.

FROM cr.loongnix.cn/loongson/loongnix-server:8.4.0

LABEL maintainer="wangweijie@loongson.cn"

RUN mkdir -p /etc/ansible \
  && echo "localhost ansible_connection=local" > /etc/ansible/hosts \
  && echo '[defaults]' > /etc/ansible/ansible.cfg \
  && echo 'roles_path = /opt/ansible/roles' >> /etc/ansible/ansible.cfg \
  && echo 'library = /usr/share/ansible/openshift' >> /etc/ansible/ansible.cfg

# Copy python dependencies specs to be installed using Pipenv
COPY Pipfile* ./
# Instruct pip(env) not to keep a cache of installed packages,
# to install into the global site-packages and
# to clear the pipenv cache as well
ENV PIP_NO_CACHE_DIR=1 \
    PIPENV_SYSTEM=1 \
    PIPENV_CLEAR=1
# Ensure fresh metadata rather than cached metadata, install system and pip python deps,
# and remove those not needed at runtime.
# pip3~=21.1 fixes a vulnerability described in https://github.com/pypa/pip/pull/9827.
RUN yum clean all && rm -rf /var/cache/yum/* \
  && yum update -y \
  && yum install -y libffi-devel openssl-devel python38-devel gcc python38-pip python38-setuptools \
  && pip3 install --upgrade pip~=21.1.0 \
  && pip3 install pipenv==2020.11.15 \
  && pipenv install --deploy \
  && yum remove -y gcc libffi-devel openssl-devel python38-devel \
  && yum clean all \
  && rm -rf /var/cache/yum

COPY ./tini /

RUN chmod +x /tini && /tini --version
