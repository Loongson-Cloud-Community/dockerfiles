
REGISTRY?=cr.loongnix.cn
ORGANIZATION?=calico
REPOSITORY?=fastdfs
TAG?=5.05

FASTDFS_SRC_URL=https://github.com/liujie-666/fastdfs.git
NGINX_SRC_URL=https://github.com/nginx/nginx.git
NGINX_MODULE_URL=https://github.com/happyfish100/fastdfs-nginx-module.git
LIBFAST_COMMON_SRC_URL=https://github.com/happyfish100/libfastcommon.git

NGINX_COMMIT=0ddad64
NGINX_MODULE_COMMIT=10d1729
LIBFAST_COMMON_COMMIT=906c9e8

IMAGE_NAME=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG)
SUBDIR = fastdfs nginx nginx_module libfastcommon

default:image

image: $(foreach dir, $(SUBDIR), src/$(dir))
	docker build -t $(IMAGE_NAME) .
src/fastdfs:
	git clone $(FASTDFS_SRC_URL) $@ 
src/nginx:
	git clone $(NGINX_SRC_URL) $@ && cd $@ && git checkout ${NGINX_COMMITI}
src/nginx_module:
	git clone $(NGINX_MODULE_URL) $@ && cd $@ && git checkout ${NGINX_MODULE_COMMIT}
src/libfastcommon:
	git clone $(LIBFAST_COMMON_SRC_URL) $@ && cd $@ && git checkout ${LIBFAST_COMMON_COMMIT}
push:
	docker push $(IMAGE_NAME)
clean:
	rm -rf src 
