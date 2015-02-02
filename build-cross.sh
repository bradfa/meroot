#!/bin/sh

set -ex

cp config.sh musl-cross/
(
	cd musl-cross
	./build.sh
)
