#!/bin/bash
set -e
echo "Building zlib.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 4.5 MB"

# 6.11. Zlib package contains compression and decompression
# routines used by some programs
tar -xf /sources/zlib-*.tar.xz -C /tmp/ \
  && mv /tmp/zlib-* /tmp/zlib \
  && pushd /tmp/zlib \
  && ./configure --prefix=/usr \
  && make \
  && make check \
  && make install \
  && mv -v /usr/lib/libz.so.* /lib \
  && ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so \
  && popd \
  && rm -rf /tmp/zlib
