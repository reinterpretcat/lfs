#!/bin/bash
set -e
echo "Building binutils.."
echo "Approximate build time: 1 SBU"
echo "Required disk space: 547 MB"

# 5.4 Binutils package contains a linker, an assembler, and other
#  tools for handling object files
tar -xf binutils-*.tar.bz2 -C /tmp/ \
  && mv /tmp/binutils-* /tmp/binutils \
  && pushd /tmp/binutils \
  && mkdir -v build \
  && cd build \
  && ../configure               \
    --prefix=/tools            \
    --with-sysroot=$LFS        \
    --with-lib-path=/tools/lib \
    --target=$LFS_TGT          \
    --disable-nls              \
    --disable-werror           \
  && make \
  && mkdir -pv /tools/lib \
  && ln -sv lib /tools/lib64 \
  && make install \
  && popd \
  && rm -rf /tmp/binutils
