#!/bin/sh

set -ex

. ./config.sh

# Get the full configuration
. musl-cross/defs.sh

BUSYBOX_VERSION=1.23.1
MAKE_VERSION=4.1
GMP_VERSION=6.0.0
MPFR_VERSION=3.1.2
MPC_VERSION=1.0.2
M4_VERSION=1.4.17
BINUTILS_VERSION=2.25

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
ln -sfv usr/bin "$PREFIX"/bin
ln -sfv usr/sbin "$PREFIX"/sbin
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

# Change PREFIX to PREFIX/usr
OLDPREFIX=$PREFIX
PREFIX=$PREFIX/usr

# Use musl-cross cross compiler
CC=$CC_PREFIX/bin/$TRIPLE-gcc
CXX=$CC_PREFIX/bin/$TRIPLE-g++
AR=$CC_PREFIX/bin/$TRIPLE-ar
AS=$CC_PREFIX/bin/$TRIPLE-as
LD=$CC_PREFIX/bin/$TRIPLE-ld
RANLIB=$CC_PREFIX/bin/$TRIPLE-ranlib
READELF=$CC_PREFIX/bin/$TRIPLE-readelf
STRIP=$CC_PREFIX/bin/$TRIPLE-strip

# Linux headers
fetchextract $LINUX_HEADERS_URL
LINUX_HEADERS_DIR=$(stripfileext $(basename $LINUX_HEADERS_URL))
if [ ! -e $LINUX_HEADERS_DIR/configured ]
then
    (
    cd $LINUX_HEADERS_DIR
    make $LINUX_DEFCONFIG ARCH=$LINUX_ARCH
    touch configured
    )
fi
if [ ! -e $LINUX_HEADERS_DIR/installedheaders ]
then
    (
    cd $LINUX_HEADERS_DIR
    make headers_install ARCH=$LINUX_ARCH INSTALL_HDR_PATH="$PREFIX"
    touch installedheaders
    )
fi

# GMP (static linked)
fetchextract http://ftpmirror.gnu.org/gmp/ gmp-$GMP_VERSION .tar.bz2
buildinstall '' gmp-$GMP_VERSION --target=$TRIPLE --host=$TRIPLE \
	--disable-shared --with-pic

# MPFR (static linked)
fetchextract http://ftp.gnu.org/gnu/mpfr/ mpfr-$MPFR_VERSION .tar.bz2
buildinstall '' mpfr-$MPFR_VERSION --target=$TRIPLE --host=$TRIPLE \
	--disable-shared --with-pic --with-gmp=$PREFIX

# MPC (static linked)
fetchextract http://ftp.gnu.org/gnu/mpc/ mpc-$MPC_VERSION .tar.gz
buildinstall '' mpc-$MPC_VERSION --target=$TRIPLE --host=$TRIPLE \
	--disable-shared --with-pic --with-gmp=$PREFIX --with-mpfr=$PREFIX

# Binutils (static linked)
fetchextract http://ftp.gnu.org/gnu/binutils/ binutils-$BINUTILS_VERSION .tar.bz2
# Store old MAKEFLAGS and override to prevent $TRIPLET naming in target
OLDMAKEFLAGS=$MAKEFLAGS
OLDMAKEINSTALLFLAGS=$MAKEINSTALLFLAGS
MAKEFLAGS="$MAKEFLAGS tooldir=$PREFIX"
MAKEINSTALLFLAGS=$MAKEFLAGS
buildinstall '' binutils-$BINUTILS_VERSION CC="$CC -static" LDFLAGS="-Wl,-static" \
	--target=$TRIPLE --host=$TRIPLE \
	--disable-nls --disable-werror \
	--with-gmp=$PREFIX --with-mpfr=$PREFIX --with-mpc=$PREFIX
MAKEFLAGS=$OLDMAKEFLAGS
MAKEINSTALLFLAGS=$OLDMAKEINSTALLFLAGS

# GNU Make (static linked)
fetchextract http://ftp.gnu.org/gnu/make/ make-$MAKE_VERSION .tar.bz2
buildinstall '' make-$MAKE_VERSION CFLAGS="-static" LDFLAGS="-static" \
	--target=$TRIPLE --host=$TRIPLE --without-guile --disable-nls

# m4 (static linked)
fetchextract http://ftp.gnu.org/gnu/m4/ m4-$M4_VERSION .tar.bz2
buildinstall '' m4-$M4_VERSION LDFLAGS="-static" \
	--target=$TRIPLE --host=$TRIPLE
