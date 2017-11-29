#!/bin/bash
set -e
echo "Building m4.."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 30 MB"

# 6.14. M4 package contains a macro processor
tar -xf /sources/m4-*.tar.xz -C /tmp/ \
  && mv /tmp/m4-* /tmp/m4 \
  && pushd /tmp/m4 \
  && ./configure --prefix=/usr \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make check; fi \
  && make install \
  && popd \
  && rm -rf /tmp/m4
