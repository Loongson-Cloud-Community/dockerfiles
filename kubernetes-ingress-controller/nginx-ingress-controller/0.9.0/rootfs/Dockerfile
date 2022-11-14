# Copyright 2015 The Kubernetes Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM cr.loongnix.cn/google_containers/nginx-slim:0.14

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
  diffutils \
  ssl-cert \
  curl \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && make-ssl-cert generate-default-snakeoil --force-overwrite

COPY . /

# https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem

#curl -sSL -o dumb-init https://github.com/Loongson-Cloud-Community/Yelp_dumb-init/releases/download/v1.2.0/dumb-init-loong64
#RUN curl -sSL -o /sbin/dumb-init https://github.com/Loongson-Cloud-Community/Yelp_dumb-init/releases/download/v1.2.0/dumb-init-loong64 && \
#  chmod +x /sbin/dumb-init
RUN mv /dumb-init /sbin/dumb-init && chmod +x /sbin/dumb-init

ENTRYPOINT ["/sbin/dumb-init", "--"]

CMD ["/nginx-ingress-controller"]
