# This file is generated by the template.

REGISTRY?=cr.loongnix.cn
ORGANIZATION?=library
REPOSITORY?=ruby
TAG?=2.5.5

IMAGE=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG)

RUBY_MAJOR?=2.5
RUBY_VERSION?=2.5.5

default: image

download:
	wget -O ruby-$(RUBY_VERSION).tar.xz "https://cache.ruby-lang.org/pub/ruby/$(RUBY_MAJOR)/ruby-$(RUBY_VERSION).tar.xz"

image: download
	docker build \
		-t $(IMAGE) \
		.

push:
	docker push $(IMAGE)
