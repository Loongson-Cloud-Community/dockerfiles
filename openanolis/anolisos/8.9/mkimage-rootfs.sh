#!/bin/sh
#
# for AnolisOS 23
# create rootfs.tar from repository
#
#set -x

set -e

arch=loongarch64
#release=$1
releasever=8
version=8.9
if [ -z $version ]
then
        echo "releasever or version is empty!!!"
        exit 1
fi

output="AnolisOS-${version}.rootfs.${arch}.tar.gz"

repos_baseos_url="https://build.openanolis.cn/kojifiles/output/anolis-8-20240318.0/compose/BaseOS/loongarch64/os/"

#trap cleanup TERM EXIT

work_dir=$(mktemp -d $(pwd)/rootfs-image.XXXXXX)
rootfs=${work_dir}/rootfs

repo_dir="${work_dir}/yum.repo.d"
repo_conf="${repo_dir}/AnolisOS.repo"
setting_scripts=setting.sh

pkg_list="
 acl basesystem bash binutils ca-certificates anolis-gpg-keys anolis-release
 anolis-repos chkconfig coreutils-single cpio cracklib crypto-policies curl
 dbus dbus-tools device-mapper dhcp-client dnf dracut dracut-network dracut-squash
 elfutils-default-yama-scope ethtool expat filesystem findutils gawk gdbm glib2
 glibc glibc-minimal-langpack gmp gnupg2 gpgme grep gzip hostname ima-evm-utils
 info ipcalc iproute iputils json-c kexec-tools kmod less lzo mpfr ncurses-base
 npth openldap p11-kit p11-kit-trust pam pcre pcre2 popt procps-ng readline rootfiles
 rpm sed setup shadow-utils snappy squashfs-tools systemd systemd-pam systemd-udev tar tzdata
 util-linux vim-minimal xz yum rdma-core libibverbs
"

####################################################################
cleanup()
{
	rm -rf ${work_dir}
}
####################################################################

mkdir -pv ${rootfs}   || :
mkdir -pv ${repo_dir} || :

####################################################################
# gen repos conf
####################################################################
cat > ${repo_conf} << EOF
[baseos]
name=AnolisOS-$releasever
baseurl=${repos_baseos_url}
gpgcheck=0
enabled=1
priority=1
excludepkgs="${exclude_pkgs}"
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-LOONGNIX
EOF
####################################################################


####################################################################
DNF_OPTS="\
	--setopt=install_weak_deps=False \
	--setopt=reposdir=${repo_dir} \
	--releasever=${releasever} \
	--installroot=${rootfs} \
	--nodocs"

echo "Install packages : $pkg_list"

rpmdb --root=${rootfs} --initdb
dnf ${DNF_OPTS} makecache --refresh
dnf ${DNF_OPTS} -y install ${pkg_list}
####################################################################

####################################################################
cat > ${rootfs}/${setting_scripts} << EOF
#!/bin/bash

## config TERM is linux
echo 'export TERM=linux' >> etc/bash.bashrc
echo 'container' > /etc/dnf/vars/infra

#Generate installtime file record
/bin/date +%Y%m%d_%H%M > /etc/BUILDTIME

# Limit languages to help reduce size.
LANG="en_US"
echo "%_install_langs $LANG" > /etc/rpm/macros.image-language-conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf

pushd /usr/share/locale > /dev/null
	ls | egrep -x -v "en|en@arabic|en@boldquot|en@cyrillic|en@greek|en@hebrew|en@piglatin|en@quot|en@shaw|en_CA|en_GB|en_US|locale.alias" | xargs rm -rf
popd > /dev/null

# systemd fixes
:> /etc/machine-id
systemd-tmpfiles --create --boot
# mask mounts and login bits
systemctl mask systemd-logind.service getty.target console-getty.service
systemctl mask sys-fs-fuse-connections.mount systemd-remount-fs.service dev-hugepages.mount

# Remove things we don't need
yum clean all > /dev/null
rm -rf /etc/udev/hwdb.bin
rm -rf /usr/lib/udev/hwdb.d/
rm -rf /boot
rm -rf /var/lib/dnf/history.*
rm -rf /usr/src/
rm -rf /home/*
rm -rf /var/log/*
rm -rf /var/cache/*
rm -rf /var/lib/yum/*
## Introduced by binutils
rm -rf /usr/bin/gdb
rm -f \$0
###########################################################################
EOF
####################################################################

chmod +x ${rootfs}/${setting_scripts}
chroot   ${rootfs} /${setting_scripts}

##解决在rootfs中su命令没有权限问题
file_list="fingerprint-auth password-auth postlogin smartcard-auth system-auth user-profile"
#for file in ${file_list}
#do
#        chroot ${rootfs} authselect create-profile ${file}
#        chroot ${rootfs} ln -s /etc/authselect/custom/${file} /etc/pam.d/${file}
#done

##解决在chroot中/dev/null没有权限问题
chroot ${rootfs} rm -rf /dev/null
chroot ${rootfs} mknod /dev/null c 1 3
chroot ${rootfs} chmod 666 /dev/null

cur_dir=$(pwd)
pushd ${rootfs} > /dev/null
	if [ -e "${cur_dir}/${output}" ]; then
		echo "Remove old ${output}"
		rm -rf "${cur_dir}/${output}"
	fi

	echo "Generating ${output} ...."
#	tar --numeric-owner --exclude='dev/*' -acf "${cur_dir}/${output}" .
	tar --numeric-owner -acf "${cur_dir}/${output}" .
popd > /dev/null

echo "Generating ${output} md5sum...."
sync && md5sum ${output} > ${output}.md5

######################################
sync && echo -e "\n^^^^^^ done ^^^^^^^^^^\n"
######################################
