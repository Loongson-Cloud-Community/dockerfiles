#!/bin/bash
set -e

: ${DISTRO:="loongnix"}
: ${RELEASE:=DaoXiangHu-stable}
: ${MIRROR_ADDRESS:=http://pkg.loongnix.cn/loongnix}
: ${ROOTFS:="rootfs.tar.gz"}
: ${APT_CONF_URL:="https://raw.githubusercontent.com/GoogleContainerTools/base-images-docker/master/debian/reproducible/overlay/etc/apt/apt.conf.d/"}

WKDIR=$1
cd ${WKDIR?}

apt update -y
apt install -y debootstrap curl
if [ ! -f /usr/share/debootstrap/scripts/$RELEASE ]; then
	ln -s /usr/share/debootstrap/scripts/sid /usr/share/debootstrap/scripts/$RELEASE
fi

TMPDIR=`mktemp -d`
cp .slimify-includes $TMPDIR/.slimify-includes
cp .slimify-excludes $TMPDIR/.slimify-excludes
# install packages
debootstrap --no-check-gpg --variant=minbase --components=main,non-free,contrib --arch=loongarch64 --foreign $RELEASE $TMPDIR $MIRROR_ADDRESS
chroot $TMPDIR debootstrap/debootstrap --second-stage

# slimify
slimIncludes=( $(sed '/^#/d;/^$/d' .slimify-includes | sort -u) )
slimExcludes=( $(sed '/^#/d;/^$/d' .slimify-excludes | sort -u) )

findMatchIncludes=()
for slimInclude in "${slimIncludes[@]}"; do
        {
                [ "${#findMatchIncludes[@]}" -eq 0 ] || findMatchIncludes+=( '-o' )
                findMatchIncludes+=( -path "$slimInclude" )
        }
done
findMatchIncludes=( '(' "${findMatchIncludes[@]}" ')' )

for slimExclude in "${slimExcludes[@]}"; do
        {
                chroot $TMPDIR \
                        find "$(dirname "$slimExclude")" \
                        -depth -mindepth 1 \
                        -not \( -type d -o -type l \) \
                        -not "${findMatchIncludes[@]}" \
                        -exec rm -f '{}' ';'
        }
done

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

while [ "$(
        chroot $TMPDIR \
                find "$(dirname "$slimExclude")" \
                -depth -mindepth 1 \( -empty -o -xtype l \) \
                -exec rm -rf '{}' ';' -printf '.' \
                | wc -c
        )" -gt 0 ]; do true; done

chroot $TMPDIR rm -rf /tmp/* /var/cache/apt/* /var/lib/apt/lists/*
tar -zcvf $ROOTFS -C $TMPDIR .
