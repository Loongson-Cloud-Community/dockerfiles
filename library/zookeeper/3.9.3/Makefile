REGISTRY?=cr.loongnix.cn
ORGANIZATION?=zookeeper
REPOSITORY?=zookeeper
TAG := release-3.9.3

IMAGE_NAME:=${REGISTRY}/${ORGANIZATION}/${REPOSITORY}:${TAG}
SOURCE_URL:=https://github.com/apache/zookeeper.git
SOURCE := $(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')


default:image

image:src/$(SOURCE) bin
	docker build -t ${IMAGE_NAME} .

src/$(SOURCE):
	git clone -b ${TAG} ${SOURCE_URL} $@

bin:src/$(SOURCE)
	cd src/${SOURCE} && ls && mvn clean package -Dmaven.test.skip=true && mvn clean package -Pdist -DskipTests 
	cd src/${SOURCE}/zookeeper-assembly/target && mkdir -p zookeeper && tar -zxvf apache-zookeeper-3.9.3-bin.tar.gz -C zookeeper --strip-components=1 
clean: 
	rm -rf src
 
