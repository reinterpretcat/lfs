#!/bin/bash
set -e
echo "Building Grep.."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 30 MB"

# 6.33. Grep package contains programs for searching through files
tar -xf /sources/grep-*.tar.xz -C /tmp/ \
  && mv /tmp/grep-* /tmp/grep \
  && pushd /tmp/grep

./configure --prefix=/usr --bindir=/bin
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
# cleanup
popd \
  && rm -rf /tmp/grep
