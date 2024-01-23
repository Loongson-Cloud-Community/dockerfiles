.DEFAULT_GOAL := docker-build-loongarch64
.PHONY: all
.PHONY: docker-build-all docker-push-all docker-manifest-rm

REGISTRY?=cr.loongnix.cn/library/qemu-user-static
TAG?=latest
DOCKERFILE?=Dockerfile
URL?=https://github.com/Loongson-Cloud-Community/qemu-user-static/releases/download/x86_abi1.0/x86_abi1.0_qemu.tar.gz
all: docker-build-all

define docker-build

.PHONY: docker-build-list-$(1)

docker-build-list += docker-build-$(1)

ifeq ($(1),loongarch64)
	DOCKERFILE := Dockerfile
	URL := https://github.com/Loongson-Cloud-Community/qemu-user-static/releases/download/abi1.0/qemu-static-abi1.0.tar.gz
endif

docker-build-$(1): download
	docker buildx build . --load -f $(DOCKERFILE)-$(1) \
		--platform linux/$(1) \
		--build-arg BASE_IMAGE=$(2) \
		--build-arg TARGETARCH=$(1) \
		-t $(REGISTRY):$(TAG)-$(1) \
		-t $(REGISTRY):latest-$(1)

.PHONY: docker-push-$(1)
docker-push-list += docker-push-$(1)
docker-push-$(1): docker-build-$(1)
	docker push $(REGISTRY):$(TAG)-$(1)

tag-list += $(REGISTRY):$(TAG)-$(1)

endef

$(eval $(call docker-build,x86_64,debian:latest))
$(eval $(call docker-build,loongarch64,cr.loongnix.cn/library/debian:buster))

docker-build-all: $(docker-build-list)
docker-push-all: $(docker-push-list)
	-docker manifest rm $(REGISTRY):$(TAG)
	-docker manifest rm $(REGISTRY):latest
	docker manifest create $(REGISTRY):$(TAG) $(tag-list)
	docker manifest push $(REGISTRY):$(TAG)
	docker manifest create $(REGISTRY):latest $(tag-list)
	docker manifest push $(REGISTRY):latest
download:
	wget -O qemu-static.tar.gz $(URL) && tar xf qemu-static.tar.gz --strip-components=1
