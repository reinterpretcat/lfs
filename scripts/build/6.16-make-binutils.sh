#!/bin/bash
set -e
echo "Building binutils.."
echo "Approximate build time: 5.8 SBU"
echo "Required disk space: 4.2 Gb"

# 6.16. Binutils package contains a linker, an assembler, and other tools
# for handling object files
tar -xf /sources/binutils-*.tar.bz2 -C /tmp/ \
  && mv /tmp/binutils-* /tmp/binutils \
  && pushd /tmp/binutils
# verify that the PTYs are working properly inside the chroot environment
expect -c "spawn ls"
mkdir -v build \
  && cd build \
  && ../configure --prefix=/usr \
       --enable-gold           \
       --enable-ld=default     \
       --enable-plugins        \
       --enable-shared         \
       --disable-werror        \
       --with-system-zlib      \
  && make tooldir=/usr         \
  && make -k check  || true    \
  && make tooldir=/usr install \
  && popd \
  && rm -rf /tmp/binutils
