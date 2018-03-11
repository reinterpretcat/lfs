#!/bin/bash
set -e
echo "Building file.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 16 MB"

# 6.12. The File package contains a utility for determining the
# type of a given file or files.
tar -xf /sources/file-*.tar.gz -C /tmp/ \
  && mv /tmp/file-* /tmp/file \
  && pushd /tmp/file

./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install

popd \
  && rm -rf /tmp/file
