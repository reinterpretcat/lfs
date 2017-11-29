#!/bin/bash
set -e
echo "Building autoconf.."
echo "Approximate build time: 3.3 SBU"
echo "Required disk space: 17.3 MB"

# 6.43. Autoconf package contains programs for producing shell scripts
# that can automatically configure source code
tar -xf /sources/autoconf-*.tar.xz -C /tmp/ \
  && mv /tmp/autoconf-* /tmp/autoconf \
  && pushd /tmp/autoconf
./configure --prefix=/usr
make
make check || check
make install
# cleanup
popd \
  && rm -rf /tmp/autoconf
