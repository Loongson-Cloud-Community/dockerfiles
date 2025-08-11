src: clean
	https_proxy= wget https://cloud.loongnix.cn/releases/loongarch64/oceanbase/oceanbase-ce/v3/oceanbase-all-in-one-v3.tar.gz
#	wget http://cloud.loongnix.xa/releases%2Floongarch64%2Foceanbase%2Foceanbase-ce%2Fv3%2Foceanbase-all-in-one-v3.tar.gz
	tar xf oceanbase-all-in-one-v3.tar.gz

image: src 
	docker buildx build \
  --memory=8g \
  --shm-size=1g \
  --ulimit stack=67108864 \
  -t cr.loongnix.cn/oceanbase/oceanbase-ce:v3 \
  -f Dockerfile . --load
#	docker buildx build -t cr.loongnix.cn/oceanbase/oceanbase-ce:v3 -f Dockerfile . --load
#	$(MAKE) clean

push: image
	docker push cr.loongnix.cn/oceanbase/oceanbase-ce:v3

clean:
	rm -rf  oceanbase-all*
