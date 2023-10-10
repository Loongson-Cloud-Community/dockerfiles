# dockerfiles

*dockerfiles* 是龙芯容器镜像的源码仓库，您可以直接通过本项目向 [cr.loongnix.cn]
提交镜像，感谢您为龙芯生态作出的贡献。

## 仓库说明

* 仓库按照 *ORGANIZATION/REPOSITORY/VERSION* 的形式组织，例如 *rook/ceph/1.8.4*
* 仓库组织与 [Docker Hub] 保持一致，*library* 表示进入 [Docker Hub] 官方仓库的镜像
* 每一个叶子目录表示一个*项目*，单次提交仅能包含一个项目
* 对于 *a.b.c* 形式的版本，不加前缀 *v*

## 使用方法

为了规范和自动化，所有项目框架均从模板中生成，默认提供了两种
模板，*generate.sh* 和 *generate-new.sh*。

### generate.sh

__使用方法__

``` bash
./generate.sh ORGANIZATION REPOSITORY VERSION
```

该模板适用于构建和源码分离的项目，例如 *kubernetes*，可以提取
项目的 *Dockerfile* 文件，并通过 *Makefile* 构建镜像。阅读
[Makefile.template](Makefile.template) 了解详情。


### generate-new.sh

__使用方法__

``` bash
./generate-new.sh ORGANIZATION REPOSITORY VERSION
```

该模板适用于构建与源码一体的项目，使用该模板可以将源码修改
以补丁的形式打入，并通过 *Makefile* 构建镜像。阅读
[Makefile-new.template](Makefile-new.template) 了解详情。

### 注意事项

__镜像修改意见__

本仓库的ci流水线会根据生成的镜像提出修改意见，类似于：

- cr.loongnix.cn/grafana/promtail:2.8.2

|    | code        | level   | alerts                                                                                                                                          |
|---:|:------------|:--------|:------------------------------------------------------------------------------------------------------------------------------------------------|
|  0 | DKL-DI-0005 | FATAL   | Use 'rm -rf /var/lib/apt/lists' after 'apt-get install|update' : |0 /bin/sh -c apt-get update &&   apt-get install -qy   tzdata ca-certificates |
|  1 | CIS-DI-0001 | WARN    | Last user should not be root                                                                                                                    |
|  2 | CIS-DI-0005 | INFO    | export DOCKER_CONTENT_TRUST=1 before docker pull/build                                                                                          |
|  3 | CIS-DI-0006 | INFO    | not found HEALTHCHECK statement                                                                                                                 |
|  4 | CIS-DI-0008 | INFO    | setuid file: urwxr-xr-x usr/bin/chsh                                                                                                            |

您需要根据修改意见对于源码或者补丁进行修改，消除修改意见中`FATAL`级别的告警。

__镜像存在多个tag__

如果构建的镜像需要添加多个`tag`，请务必在`make image`阶段进行添加。

## 如何贡献

欢迎贡献 [CONTRIBUTING.md](CONTRIBUTING.md)


<!-- footer -->
[Docker Hub]: https://hub.docker.com
[cr.loongnix.cn]: https://cr.loongnix.cn
