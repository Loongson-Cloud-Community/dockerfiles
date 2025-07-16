src: clean
	wget https://cloud.loongnix.cn/releases/loongarch64/oceanbase/oceanbase-ce/v3/oceanbase-all-in-one-v3.tar.gz
	tar xf oceanbase-all-in-one-v3.tar.gz

image: 
	docker buildx build -t cr.loongnix.cn/oceanbase/oceanbase-ce:v3 -f Dockerfile . --load
	$(MAKE) clean

push: image
	docker push cr.loongnix.cn/oceanbase/oceanbase-ce:v3

clean:
	rm -rf  oceanbase-all*
