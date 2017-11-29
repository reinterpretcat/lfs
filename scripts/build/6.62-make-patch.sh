#!/bin/bash
set -e
echo "Building patch.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 11 MB"

# 6.62. Patch package contains a program for modifying or creating files
# by applying a “patch” file typically created by the diff program
tar -xf /sources/patch-*.tar.xz -C /tmp/ \
  && mv /tmp/patch-* /tmp/patch \
  && pushd /tmp/patch

./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
# cleanup
popd \
  && rm -rf /tmp/patch
