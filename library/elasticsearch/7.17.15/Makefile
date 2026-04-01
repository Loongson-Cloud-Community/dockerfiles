REGISTRY     ?=cr.loongnix.cn
ORGANIZATION ?=elastic
REPOSITORY  ?=elasticsearch
TAG          ?= 7.17.15

IMAGE=${REGISTRY}/${ORGANIZATION}/${REPOSITORY}:${TAG}

default: image

image:
	docker build \
	    --build-arg TAG=${TAG} \
	    -t ${IMAGE} \
	    .

push:
	docker push $(IMAGE)

clean: 
