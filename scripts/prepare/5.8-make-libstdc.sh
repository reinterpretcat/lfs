#!/bin/bash
set -e
echo "Building libstdc.."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 752 MB"

# 5.8. Libstdc++ is the standard C++ library. It is needed for
# the correct operation of the g++ compile
tar -xf gcc-*.tar.xz -C /tmp/ \
  && mv /tmp/gcc-* /tmp/gcc \
  && pushd /tmp/gcc \
  && mkdir -v build \
  && cd build \
  && ../libstdc++-v3/configure        \
     --host=$LFS_TGT                 \
     --prefix=/tools                 \
     --disable-multilib              \
     --disable-nls                   \
     --disable-libstdcxx-threads     \
     --disable-libstdcxx-pch         \
     --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/7.3.0 \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/gcc
