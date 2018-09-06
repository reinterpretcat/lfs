#!/bin/bash
set -e
echo "Building Autoconf.."
echo "Approximate build time: less than 0.1 SBU (about 3.2 SBU with tests)"
echo "Required disk space: 17.3 MB"

# 6.43. Autoconf package contains programs for producing shell scripts
# that can automatically configure source code
tar -xf /sources/autoconf-*.tar.xz -C /tmp/ \
  && mv /tmp/autoconf-* /tmp/autoconf \
  && pushd /tmp/autoconf

./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make check || true; fi
make install
# cleanup
popd \
  && rm -rf /tmp/autoconf
