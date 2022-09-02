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

## 镜像命名规范
1. 以 a.b.c 为版本号的镜像，统一不带 v 标签，如果确实需要的话，在 `Makefile` 中以别名的方式进行二次命名，不带 v 标签需要体现在 `dockerfiles` 源码目录上，即目录名尽量不含 v 标签。
