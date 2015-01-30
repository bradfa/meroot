MeRoot
======

Build a minimal root file system which is usable enough to compile itself and to
install and use [pkgsrc][pkgsrc].  The goal is to be like a BSD, where the core
system is build-able by itself but all software packages are built from pkgsrc.

[pkgsrc]: http://www.pkgsrc.org/

Use [musl-cross][musl-cross] and then expand on it just like in [CLFS][clfs] and
[Aboriginal Linux][aboriginal].

[musl-cross]: https://bitbucket.org/GregorR/musl-cross
[clfs]: http://clfs.org
[aboriginal]: http://landley.net/aboriginal/

## Instructions

1. Clean with `./clean.sh`
2. Configure for your desires by editing `config.sh`
3. Build a cross compiler with `./build-cross.sh` (just uses musl-cross)
4. Build a root file system with `./build-rootfs.sh`
5. Chroot into the rootfs or setup a bootloader and kernel to boot into it