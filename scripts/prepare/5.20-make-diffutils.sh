#!/bin/bash
set -e
echo "Building diffutils.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 22 MB"

# 5.20. Diffutils package contains programs that show the differences
# between files or directories
tar -xf diffutils-*.tar.xz -C /tmp/ \
  && mv /tmp/diffutils-* /tmp/diffutils \
  && pushd /tmp/diffutils \
  && ./configure --prefix=/tools \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make check; fi \
  && make install \
  && popd \
  && rm -rf /tmp/diffutils
