# This file is generated by the template.

REGISTRY?=cr.loongnix.cn
ORGANIZATION?=library
REPOSITORY?=ruby
TAG?=2.5.9-alpine

IMAGE=$(REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG)

RUBY_VERSION?=2.5.9
RUBY_MAJOR?=2.5

default: image

download:
	wget -O ruby-$(RUBY_VERSION).tar.xz "https://cache.ruby-lang.org/pub/ruby/$(RUBY_MAJOR)/ruby-$(RUBY_VERSION).tar.xz" && \
	wget -O 'thread-stack-fix.patch' 'https://bugs.ruby-lang.org/attachments/download/7081/0001-thread_pthread.c-make-get_main_stack-portable-on-lin.patch' --no-check-certificate
	

image: download
	docker build \
		-t $(IMAGE) \
		.

push:
	docker push $(IMAGE)
