#!/bin/sh

set -ex

. ./config.sh

BUSYBOX_VERSION=1.23.1
MAKE_VERSION=4.1

# Get the full configuration
. musl-cross/defs.sh

PREFIX=$ROOTFS_BASE_PREFIX

# Create rootfs directory structure
mkdir -pv "$PREFIX"/boot
mkdir -pv "$PREFIX"/dev
mkdir -pv "$PREFIX"/etc
mkdir -pv "$PREFIX"/home
mkdir -pv "$PREFIX"/lib/modules
mkdir -pv "$PREFIX"/lib/firmware
mkdir -pv "$PREFIX"/mnt
mkdir -pv "$PREFIX"/proc
mkdir -pv "$PREFIX"/srv
mkdir -pv "$PREFIX"/usr/local
mkdir -pv "$PREFIX"/usr/bin
mkdir -pv "$PREFIX"/usr/sbin
mkdir -pv "$PREFIX"/usr/include
mkdir -pv "$PREFIX"/usr/lib
mkdir -pv "$PREFIX"/usr/pkg
mkdir -pv "$PREFIX"/usr/share
mkdir -pv "$PREFIX"/usr/src
mkdir -pv "$PREFIX"/var/cache
mkdir -pv "$PREFIX"/var/lib
mkdir -pv "$PREFIX"/var/local
mkdir -pv "$PREFIX"/var/lock
mkdir -pv "$PREFIX"/var/log
mkdir -pv "$PREFIX"/var/run
ln -sv usr/bin "$PREFIX"/bin
ln -sv usr/sbin "$PREFIX"/sbin
install -dv -m 0750 "$PREFIX"/root
install -dv -m 1777 "$PREFIX"/tmp

# Copy rootfs-overlay into the directory structure
cp -Rvn "$PWD"/root-overlay/* "$PREFIX"/

# Busybox (static linked)
fetchextract http://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
if [ ! -e busybox-$BUSYBOX_VERSION/configured ]
then
	(
	cd busybox-$BUSYBOX_VERSION
	make defconfig
	# Disable ifplugd and inetd
	sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
	sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config
	sed -i 's/# \(CONFIG_STATIC\).*/\1=y/' .config
	touch configured
	)
fi
if [ ! -e busybox-$BUSYBOX_VERSION/built ]
then
	(
	cd busybox-$BUSYBOX_VERSION
	make CROSS_COMPILE="$CC_PREFIX"/bin/"$TRIPLE"- "$MAKEFLAGS"
	touch built
	)
fi
if [ ! -e busybox-$BUSYBOX_VERSION/installed ]
then
	(
	cd busybox-$BUSYBOX_VERSION
	make CROSS_COMPILE="$CC_PREFIX"/bin/"$TRIPLE"- CONFIG_PREFIX="$PREFIX" install
	touch installed
	)
fi

