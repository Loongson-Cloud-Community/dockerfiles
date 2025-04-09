#!/bin/bash
set -ex

: ${DISTRO:="loongnix"}
: ${RELEASE:=DaoXiangHu-stable}
: ${MIRROR_ADDRESS:=https://pkg.loongnix.cn/loongnix}
: ${ROOTFS:="rootfs.tar.xz"}
: ${APT_CONF_URL:="https://raw.githubusercontent.com/GoogleContainerTools/base-images-docker/master/debian/reproducible/overlay/etc/apt/apt.conf.d"}

OUTPUT=$(cd "$(dirname $0)";pwd)
cd ${OUTPUT?}

apt update -y > /dev/null 2>&1
apt install -y debootstrap curl xz-utils > /dev/null 2>&1
if [ ! -f /usr/share/debootstrap/scripts/$RELEASE ]; then
	ln -s /usr/share/debootstrap/scripts/sid /usr/share/debootstrap/scripts/$RELEASE
fi

TMPDIR=$(mktemp -d)

# install packages
debootstrap --no-check-gpg --variant=minbase --components=main,non-free,contrib --arch=loongarch64 --foreign $RELEASE $TMPDIR $MIRROR_ADDRESS > /dev/null 2>&1
chroot $TMPDIR debootstrap/debootstrap --second-stage > /dev/null 2>&1

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

# slimify
cp .slimify-includes $TMPDIR/.slimify-includes
cp .slimify-excludes $TMPDIR/.slimify-excludes

slimIncludes=( $(sed '/^#/d;/^$/d' .slimify-includes | sort -u) )
slimExcludes=( $(sed '/^#/d;/^$/d' .slimify-excludes | sort -u) )

# package excludes
pkgExcludes='loongnix-gpu-driver-service,loonggpu-compiler,loonggl-dev'
pkgIncludes='libncursesw6,libseccomp2,sysvinit-utils,ca-certificates'

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
  for group in systemd-journal; do
      if getent group $group >/dev/null; then
          groupdel $group
      fi
  done
' -- $pkgIncludes $pkgExcludes

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
                        -exec rm -rf '{}' ';' \
                        || echo "${slimExclude} not found"
        }
done


while [ "$(
        chroot $TMPDIR \
                find "$(dirname "$slimExclude")" \
                -depth -mindepth 1 \( -empty -o -xtype l \) \
                -exec rm -rf '{}' ';' -printf '.' \
                | wc -c
        )" -gt 0 ]; do true; done

# remove slimify files
rm $TMPDIR/.slimify-excludes
rm $TMPDIR/.slimify-includes

chroot $TMPDIR rm -rf /tmp/* /var/cache/apt/* /var/lib/apt/lists/*

# tar
tarArgs=(
	--create
	--file "rootfs.tar"
	--auto-compress
	--directory "$TMPDIR"
	--exclude-from ".tar-excludes"
)

tarArgs+=(
	--numeric-owner
	--transform 's,^./,,'
	--sort name
	.
)

tar "${tarArgs[@]}"
xz -z rootfs.tar
