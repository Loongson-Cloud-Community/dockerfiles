REGISTRY?=cr.loongnix.cn
ORGANIZATION?=calico
REPOSITORY?=telegraf
TAG?=1.33.0

IMAGE_NAME := ${REGISTRY}/${ORGANIZATION}/${REPOSITORY}:$(TAG)
SOURCE_URL := https://github.com/influxdata/telegraf.git
SOURCE := $(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')
default:image

image: src/$(SOURCE)
	docker build -t $(IMAGE_NAME) .

src/$(SOURCE):
	git clone -b v1.33.0  $(SOURCE_URL) $@
clean:
	rm -rf src
