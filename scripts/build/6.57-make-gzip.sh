#!/bin/bash
set -e
echo "Building .."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 19 MB"

# 6.57. Gzip package contains programs for compressing and decompressing files
tar -xf /sources/gzip-*.tar.xz -C /tmp/ \
  && mv /tmp/gzip-* /tmp/gzip \
  && pushd /tmp/gzip

./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
mv -v /usr/bin/gzip /bin
# cleanup
popd \
  && rm -rf /tmp/gzip
