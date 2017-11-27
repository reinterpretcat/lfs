#!/bin/bash
set -e
echo "Building glibc.."
echo "Approximate build time: 4.2 SBU"
echo "Required disk space: 790 MB"

# 5.7. Glibc package contains the main C library. This library provides
# the basic routines for allocating memory, searching directories, opening
# and closing files, reading and writing files, string handling, pattern
# matching, arithmetic, and so on
tar -xf glibc-*.tar.xz -C /tmp/ \
  && mv /tmp/glibc-* /tmp/glibc \
  && pushd /tmp/glibc \
  && mkdir -v build \
  && cd build \
  && ../configure                       \
    --prefix=/tools                    \
    --host=$LFS_TGT                    \
    --build=$(../scripts/config.guess) \
    --enable-kernel=3.2                \
    --with-headers=/tools/include      \
    libc_cv_forced_unwind=yes          \
    libc_cv_c_cleanup=yes              \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/glibc

# perform a sanity check that basic functions (compiling and linking)
# are working as expected
echo 'int main(){}' > dummy.c \
  && $LFS_TGT-gcc dummy.c \
  && readelf -l a.out | grep ': /tools' \
  && rm -v dummy.c a.out
