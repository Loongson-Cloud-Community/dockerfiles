#!/bin/bash

DISTRO=loongnix
RELEASE=DaoXiangHu-stable
MIRROR_ADDRESS=http://pkg.loongnix.cn/loongnix/

## 检测 debootstrap 命令存在
if ! $(command -v debootstrap > /dev/null); then
	echo "command debootstrap not found"
	exit 1
fi

WKDIR=`mktemp -d`
mkdir -pv $WKDIR/iso
pushd $WKDIR

if [ ! -f /usr/share/debootstrap/scripts/$RELEASE ]; then
	ln -s /usr/share/debootstrap/scripts/sid /usr/share/debootstrap/scripts/$RELEASE
fi

debootstrap --no-check-gpg --variant=minbase --components=main,non-free,contrib --arch=loongarch64 --foreign $RELEASE iso $MIRROR_ADDRESS

chroot iso debootstrap/debootstrap --second-stage

tar -zcvf $DISTRO-$RELEASE.rootfs.tar.gz -C iso .
popd

mv $WKDIR/$DISTRO-$RELEASE.rootfs.tar.gz .
rm -rf WKDIR
