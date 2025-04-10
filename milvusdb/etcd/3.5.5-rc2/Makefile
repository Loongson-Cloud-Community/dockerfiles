src: clean
	git clone --depth 1 -b loongarch64-3.5.5-r3 https://github.com/Loongson-Cloud-Community/bitnami-docker-etcd src
	cd src && git apply ../0001-update-Dockerfile.patch
image: src
	cd src/3.5/debian-11 && docker build --build-arg https_proxy=$(https_proxy) -t cr.loongnix.cn/milvusdb/etcd:3.5.5-r3 -f Dockerfile .

push:
	docker push cr.loongnix.cn/milvusdb/etcd:3.5.5-r3

clean:
	rm -rf src
