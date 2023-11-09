#!/bin/bash
# Given a path by $1, generate a rootfs under that path.

set -ex

: ${MIRROR_ADDRESS:="http://pkg.loongnix.cn/loongnix"}
: ${RELEASE:="DaoXiangHu-stable"}
: ${ROOTFS:="rootfs.tar.xz"}
: ${APT_CONF_URL:="https://raw.githubusercontent.com/GoogleContainerTools/base-images-docker/master/debian/reproducible/overlay/etc/apt/apt.conf.d/"}

DISTRO=loongnix

OUTPUT=$(cd $(dirname $0); pwd)
cd ${OUTPUT?}

apt update
apt install -y curl debootstrap xz-utils
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

# https://github.com/GoogleContainerTools/base-images-docker/tree/master/debian/reproducible/overlay/etc/apt/apt.conf.d
apt_conf=(
    apt-retry
    docker-autoremove-suggests
    docker-clean
    docker-gzip-indexes
)

for apt_file in ${apt_conf[@]};do
    curl -o $TMPDIR/etc/apt/apt.conf.d/${apt_file} -sSL ${APT_CONF_URL}/${apt_file}
done

pkgExcludes='loongnix-gpu-driver-service,loonggpu-compiler,loonggl-dev'
pkgIncludes='libncursesw6,libseccomp2,sysvinit-utils'
chroot $TMPDIR bash -c '
  apt-get -o apt-get -o Acquire::Check-Valid-Until=false update -qq
  if apt-mark --help &> /dev/null; then
    apt-mark auto ".*" > /dev/null
  fi
  if [ -n "$1" ]; then
    IFS=","; includePackages=( $1 ); unset IFS
    apt-get install -y --no-install-recommends "${includePackages[@]}"
  fi
  if [ -n "$2" ]; then
    IFS=","; excludePackages=( $2 ); unset IFS
    apt-get autoremove -y --purge --allow-remove-essential "${excludePackages[@]}"
  fi
  for user in systemd-timesync systemd-network systemd-resolve; do
      if id $user >/dev/null; then
          userdel --force --remove $user
      fi
  done
' -- $pkgIncludes $pkgExcludes

# package rootfs.tar.gz
tar -cJvf $ROOTFS -C $TMPDIR .
