#src: clean
#	git clone --depth 1 -b loong64-4.13.0 https://github.com/Loongson-Cloud-Community/chirpstack src
src: clean
	https_proxy= wget https://cloud.loongnix.cn/releases/loongarch64abi1/chirpstack/chirpstack/4.13.0/chirpstack
#binary: src
#	cd src && make dist-la

image: src 
	docker build -t cr.loongnix.cn/chirpstack/chirpstack:4.0.13 -f Dockerfile .
#	cd src && docker build --build-arg https_proxy=$(https_proxy) -t cr.loongnix.cn/chirpstack/chirpstack/4.0.13 -f Dockerfile .
push:
	docker push cr.loongnix.cn/chirpstack/chirpstack:4.0.13

clean:
	rm -rf src chirpstack
