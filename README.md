# dockerfiles

龙芯容器镜像 Dockerfile 源码库

## 脚本使用方法
该脚本的目的是方便新增仓库时初始化目录和 `Makefile` 模板。
例如要新增一个 `cr.loongnix.cn/loongson/loongnix:20` 项目，执行
```
./generate.sh loongson loongnix 20
```
即可生成目录`loongson/loongnix/20` 以及适合该项目的 `Makefile`。
这个`Makefile`的作用是执行 `make image` 可构建出该镜像，执行 `make push` 可推送镜像到 `cr.loongnix.cn`。所以需要根据实际项目情况，适当增加或修改`Makefile`中的内容以达到该目的。
