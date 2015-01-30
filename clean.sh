#!/bin/sh
set -ex
rm -rf busybox-*
rm -rf make-*
rm -rf linux-*
(
cd "$PWD"/musl-cross
. "$PWD"/clean.sh
)
