#!/bin/bash
set -e
echo "Building Xz.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 15 MB"

# 6.45. Xz package contains programs for compressing and decompressing files.
# It provides capabilities for the lzma and the newer xz compression formats
tar -xf /sources/xz-*.tar.xz -C /tmp/ \
  && mv /tmp/xz-* /tmp/xz \
  && pushd /tmp/xz

./configure --prefix=/usr      \
    --disable-static           \
    --docdir=/usr/share/doc/xz-5.2.3
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
mv -v /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
# cleanup
popd \
  && rm -rf /tmp/xz
