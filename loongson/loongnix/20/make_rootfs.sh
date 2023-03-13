#!/bin/bash
# Given a path by $1, generate a rootfs under that path.

set -ex

: ${MIRROR_ADDRESS:="http://pkg.loongnix.cn/loongnix"}
: ${RELEASE:="DaoXiangHu-stable"}
: ${ROOTFS:="rootfs.tar.gz"}
DISTRO=loongnix

WKDIR=$1
cd ${WKDIR?}

apt install -y debootstrap
# loongnix do not have $RELEASE file, fix it!
if [ ! -f /usr/share/debootstrap/scripts/$RELEASE ]; then
	ln -s /usr/share/debootstrap/scripts/sid /usr/share/debootstrap/scripts/$RELEASE
fi

# create a directory for rootfs
TMPDIR=`mktemp -d`
# install packages
debootstrap --no-check-gpg --variant=minbase --components=main,non-free,contrib --arch=loongarch64 --foreign $RELEASE $TMPDIR $MIRROR_ADDRESS
chroot $TMPDIR debootstrap/debootstrap --second-stage
chroot $TMPDIR rm -rf /tmp/* /var/cache/apt/* /var/lib/apt/lists/*
# package rootfs.tar.gz
tar -zcvf $ROOTFS -C $TMPDIR .
