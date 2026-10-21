# PostgreSQL 17 Alpine 3.11 (ABI 1.0)

本目录为龙芯 **ABI 1.0（旧世界）** 的 PostgreSQL 17 Alpine 镜像。

## 构建

```bash
docker build --network=host -t cr.loongnix.cn/library/postgres:17-alpine3.11 .

说明

基础镜像：cr.loongnix.cn/library/alpine:3.11
软件源：alpine.loongnix.cn/v3.11（构建时需 --network=host）
PostgreSQL 17.11 从源码编译，使用 Alpine 3.11 自带的 gcc 8.3.0
已验证可在麒麟 V10（loongarch64, musl）上运行
