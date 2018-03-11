#!/bin/bash
set -e
echo "Building binutils.."
echo "Approximate build time: 1.1 SBU"
echo "Required disk space: 574 MB"

# 5.9. Pass 2 Binutils package contains a linker, an assembler,
# and other tools for handling object files
tar -xf binutils-*.tar.xz -C /tmp/ \
  && mv /tmp/binutils-* /tmp/binutils \
  && pushd /tmp/binutils \
  && mkdir -v build \
  && cd build \
  && CC=$LFS_TGT-gcc              \
    AR=$LFS_TGT-ar               \
    RANLIB=$LFS_TGT-ranlib       \
    ../configure                 \
      --prefix=/tools            \
      --disable-nls              \
      --disable-werror           \
      --with-lib-path=/tools/lib \
      --with-sysroot             \
  && make \
  && make install \
  && make -C ld clean \
  && make -C ld LIB_PATH=/usr/lib:/lib \
  && cp -v ld/ld-new /tools/bin \
  && popd \
  && rm -rf /tmp/binutils
