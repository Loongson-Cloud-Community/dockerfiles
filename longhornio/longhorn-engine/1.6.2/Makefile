# This file is generated by the template.

REGISTRY?=cr.loongnix.cn
ORGANIZATION?=longhornio
REPOSITORY?=longhorn-engine
TAG?=1.6.2
LATEST?=true

IMAGE=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG)
LATEST_IMAGE=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):latest

# SOURCE_URL is a url to download source, such as https://github.com/merore/merore.git.
# SOURCE is project sources, its located at src/$(SORUCE).
# PATCH is a patch that supports loong64 to $(SOURCE).
# Be sure to fill in the follows!!!
SOURCE_URL=https://github.com/longhorn/$(REPOSITORY)
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')
PATCH=0001-port-to-loong64.patch

default: image

image: go-env src/$(SOURCE)
	cd src/$(SOURCE) &&  \
	wget https://github.com/Loongson-Cloud-Community/longhorn-engine/releases/download/v1.6.2/longhorn && \
	chmod +x longhorn && mkdir bin && mv longhorn bin/ && \
	bash scripts/package 

go-env:
	cd /usr/local && \
	wget http://ftp.loongnix.cn/toolchain/golang/go-1.22/abi1.0/go1.22.4.linux-loong64.tar.gz && tar xf go1.22.4.linux-loong64.tar.gz && \
	export PATH=/usr/local/go/bin:$(PATH)

src/$(SOURCE): libqcow
	git clone -b v$(TAG) --depth=1 $(SOURCE_URL) $@
	cd $@ && \
		git apply ../../$(PATCH)

libqcow:
	wget https://s3-us-west-1.amazonaws.com/rancher-longhorn/libqcow-alpha-20181117.tar.gz && tar xf  libqcow-alpha-20181117.tar.gz && \
	cd libqcow-20181117 && \
	wget -O config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' && \
	wget -O config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' && \
	./configure && \
	make -j$(nproc) && \
	make install && \
	ldconfig

push:
	docker push $(IMAGE)
	@if [ $(LATEST) = "true" ]; \
		then\
		docker tag $(IMAGE) $(LATEST_IMAGE); \
		docker push $(LATEST_IMAGE); \
	fi

clean:
	rm -rf src libqcow* /usr/local/go1.22.4.linux-loong64.tar.gz /usr/local/go
