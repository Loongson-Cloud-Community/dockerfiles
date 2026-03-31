REGISTRY     ?=cr.loongnix.cn
ORGANIZATION ?=library
REPOSITORY  ?=zookeeper
TAG          ?= 3.9.5

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
	rm -rf src
 
