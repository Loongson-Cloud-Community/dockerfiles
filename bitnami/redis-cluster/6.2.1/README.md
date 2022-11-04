这两个tar 包制作过程：
6.2/debian-10/tar-gz/gosu-1.12.0-2-linux-loong64-debian-10.tar.gz
6.2/debian-10/tar-gz/redis-6.2.1-0-linux-loong64-debian-10.tar.gz

(1)从官方拉取x86的包
curl --remote-name --silent https://downloads.bitnami.com/files/stacksmith/gosu-1.12.0-2-linux-amd64-debian-10.tar.gz 
curl --remote-name --silent https://downloads.bitnami.com/files/stacksmith/redis-6.2.1-0-linux-amd64-debian-10.tar.gz
解压这两个包，将包中的二进制替换为LA架构的二进制

(2)gosu二进制制作
源码：https://github.com/Loongson-Cloud-Community/gosu/tree/1.12-loong64
制作过程： https://github.com/Loongson-Cloud-Community/gosu/blob/1.12-loong64/Readme-LA.md

(3)redis二进制制作
源码：https://github.com/Loongson-Cloud-Community/redis/tree/6.2.1-loongarch64
制作过程：https://github.com/Loongson-Cloud-Community/redis/blob/6.2.1-loongarch64/Readme-LA.md
