#!/bin/bash
set -e
echo "Building gawk.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 36 MB"

# 6.52. Gawk package contains programs for manipulating text files
tar -xf /sources/gawk-*.tar.xz -C /tmp/ \
  && mv /tmp/gawk-* /tmp/gawk \
  && pushd /tmp/gawk

./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
# install docs
mkdir -v /usr/share/doc/gawk-4.1.4
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.4
# cleanup
popd \
  && rm -rf /tmp/gawk
