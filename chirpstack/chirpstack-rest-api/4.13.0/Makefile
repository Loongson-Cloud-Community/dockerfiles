src: clean
	git clone --depth 1 -b abi1.0-4.13.0 https://github.com/Loongson-Cloud-Community/chirpstack-rest-api src
image: src
	cd src && docker build --build-arg https_proxy=$(https_proxy) -t cr.loongnix.cn/chirpstack/chirpstack-rest-api:4.13.0  .
push:
	docker push cr.loongnix.cn/chirpstack/chirpstack-rest-api:4.13.0
clean:
	rm -rf src
