default: image push
src: clean
	git clone --depth 1 -b loongarch-2.5.7-abi1 https://github.com/Loongson-Cloud-Community/milvus milvus-loongarch-2.5.7-abi1
	wget https://github.com/Loongson-Cloud-Community/milvus/releases/download/loongarch-2.5.7-abi1/milvus-2.5.7-linux-loong64.tar.gz

image: src
	cd milvus-loongarch-2.5.7-abi1 && tar xf ../milvus-2.5.7-linux-loong64.tar.gz && bash build/build_image.sh

push:
	docker push cr.loongnix.cn/milvusdb/milvus:2.5.7

clean:
	rm -rf milvus-loongarch-2.5.7-abi1 milvus-2.5.7-linux-loong64.tar.gz

