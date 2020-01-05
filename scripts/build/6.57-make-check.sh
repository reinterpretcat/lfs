#!/bin/bash
set -e
echo "Building Check.."
echo "Approximate build time: 0.1 SBU (about 3.8 SBU with tests)"
echo "Required disk space: 12 MB"

# 6.57. Check is a unit testing framework for C.
tar -xf /sources/check-*.tar.gz -C /tmp/ \
  && mv /tmp/check-* /tmp/check \
  && pushd /tmp/check

./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install

# cleanup
popd \
  && rm -rf /tmp/check
