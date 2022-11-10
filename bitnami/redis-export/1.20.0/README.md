### 1. tar 包制作
* redis-exporter-1.20.0-0-linux-loong64-debian-10.tar.gz   

从官方拉取x86的包   
> curl https://downloads.bitnami.com/files/stacksmith/redis-exporter-1.20.0-0-linux-amd64-debian-10.tar.gz     
解压这个包，将包中的二进制替换为LA架构的二进制    

### 2. redis-exporter二进制制作   
见：https://github.com/Loongson-Cloud-Community/redis_exporter/blob/v1.20.0-loongarch64/Readme-LA.md   

### 3. 镜像制作
make
