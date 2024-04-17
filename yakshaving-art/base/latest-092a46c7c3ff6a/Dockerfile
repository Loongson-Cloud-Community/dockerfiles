# hadolint ignore=DL3007
FROM cr.loongnix.cn/library/alpine:3.11.11
LABEL maintaner="zhaixiaojuan@loongson.cn" \
      description="Image we use as a base alpine image"

# This is a multiarch image
ARG TARGETOS
ARG TARGETARCH

COPY unhoard.sh /usr/local/bin
COPY .gitlab.d/ci /mnt/
COPY .trivyignore /

RUN \
	apk -qq --no-cache upgrade \
	&& apk -qq --no-cache add \
		bash \
		ca-certificates \
		coreutils \
		curl \
		jq \
		musl \
		git \
		openssh-server openssh-client openssh \
#		openssh-client-default \
		parallel \
		sed \
	&& wget -O /bin/trivy  https://github.com/Loongson-Cloud-Community/trivy/releases/download/v0.50.0-loong64/trivy-v0.50.0-loong64-abi1.0 \
	&& wget -O /bin/goss   https://github.com/Loongson-Cloud-Community/goss/releases/download/v0.4.6/goss-v0.4.6-loong64-abi1.0

# go1.21
#RUN \
#	git clone --depth 1 --branch v0.50.1 https://github.com/aquasecurity/trivy \
#	&& cd trivy \
#	&& CGO_ENABLED=0 go install ./cmd/tirvy ; \
#	git clone --depth 1 --branch v0.4.6  https://github.com/goss-org/goss.git \
#	&& cd goss \
#	&& GOOS=linux GOARCH=loong64 CGO_ENABLED=0 go build -ldflags "-X main.version=0.4.6 -s -w" -o goss ./cmd/goss

RUN \
	chmod 0666 /usr/local/bin/unhoard.sh \
	&& chmod +x /bin/trivy && chmod +x /bin/goss \
#        && bash /mnt/scripts/skkrty_inside_build.sh \
#	&& bash /mnt/scripts/tests_inside_build.sh \
	&& echo "done"

CMD ["bash"]
