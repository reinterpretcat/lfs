#!/bin/bash
set -e
echo "Building libtool.."
echo "Approximate build time: 1.8 SBU"
echo "Required disk space: 43 MB"

# 6.35. Libtool package contains the GNU generic library support script. It wraps
# the complexity of using shared libraries in a consistent, portable interface
tar -xf /sources/libtool-*.tar.xz -C /tmp/ \
  && mv /tmp/libtool-* /tmp/libtool \
  && pushd /tmp/libtool

./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
# Five tests are known to fail in the LFS build environment due to a circular
# dependency, but all tests pass if rechecked after automake is installed
make install || true
# cleanup
popd \
  && rm -rf /tmp/libtool
