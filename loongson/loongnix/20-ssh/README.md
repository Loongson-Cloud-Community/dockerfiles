### Description

```
  本基础镜像是服务于容器云定制化基础镜像，主要是增加ssh、systemct及其他基础命令等服务。
默认密码是Loongson@123,启用systemctl需要在pod启动时开启特权模式并添加命令/usr/sbin/init。
添加/usr/sbin/init命令后需要容器启动后再手动启动ssh服务。
```
