REGISTRY	?=cr.loongnix.cn
ORGANIZATION	?=henrygd
REPOSITORY	?=beszel
TAG		?=0.18.8
LATEST		?=true

IMAGE=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG)
IMAGE_AGENT=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY)-agent:$(TAG)
LATEST_IMAGE=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):latest
LATEST_IMAGE_AGENT=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY)-agent:latest
SOURCE_URL=https://github.com/henrygd/beszel.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

default: image

src/$(SOURCE):
	git clone -b v$(TAG) --depth 1 $(SOURCE_URL) $@
	mkdir -p $@/internal/site/dist
	unzip -q beszel-hub-static-assets-v0.18.8.zip -d $@/internal/site/dist

image: src/$(SOURCE)
	docker build \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(https_proxy) \
		-f dockerfile_hub \
		-t $(IMAGE) \
		src/$(SOURCE)
	docker build \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(https_proxy) \
		-f dockerfile_agent \
		-t $(IMAGE_AGENT) \
		src/$(SOURCE)

push:
	docker push $(IMAGE)
	docker push $(IMAGE_AGENT)
	#latest image
	@if [ $(LATEST) = "true" ]; \
		then \
		docker tag $(IMAGE) $(LATEST_IMAGE); \
		docker tag $(IMAGE_AGENT) $(LATEST_IMAGE_AGENT); \
		docker push $(LATEST_IMAGE); \
		docker push $(LATEST_IMAGE_AGENT); \
	fi

clean:
	rm -rf src
