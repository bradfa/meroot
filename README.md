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

1. Clone this repo to your machine `git clone https://github.com/bradfa/meroot`
2. Go into the meroot directory `cd meroot`
3. Get the musl-cross git submodule and update it `git submodule init && git submodule update`
4. Clean with `./clean.sh`
5. Configure for your desires by editing `config.sh`
6. Build a cross compiler with `./build-cross.sh` (just uses musl-cross)
7. Build a root file system with `./build-rootfs.sh`
8. Chroot into the rootfs or setup a bootloader and kernel to boot into it
9. Build musl using `./configure --prefix=/ --includedir=/usr/include && make && make install`
10. Fetch a pkgsrc tarball and bootstrap it
11. Attempt to build packages from pkgsrc using bmake
