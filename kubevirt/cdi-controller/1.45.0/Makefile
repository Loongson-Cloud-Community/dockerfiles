# This file is generated by the template.

REGISTRY?=cr.loongnix.cn
ORGANIZATION?=kubevirt
REPOSITORY?=cdi-controller
TAG?=1.45.0

IMAGE=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG)


default: image

download: clean
	wget "https://github.com/Loongson-Cloud-Community/containerized-data-importer/releases/download/v1.45.0/cdi-controller"
	chmod 755 cdi-controller

image: download
	docker build \
		-t $(IMAGE) \
		.

push:
	docker push $(IMAGE)

clean:
	rm -f cdi-controller
