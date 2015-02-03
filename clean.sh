#!/bin/sh
set -ex
rm -rf busybox-*
rm -rf make-*
rm -rf linux-*
rm -rf kernel-headers-*
rm -rf m4-*
rm -rf mpc-*
rm -rf gmp-*
rm -rf mpfr-*
rm -rf binutils-*
(
cd "$PWD"/musl-cross
. "$PWD"/clean.sh
)
