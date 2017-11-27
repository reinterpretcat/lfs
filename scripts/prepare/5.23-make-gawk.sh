#!/bin/bash
set -e
echo "Building gawk.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 35 MB"

# 5.23. Gawk package contains programs for manipulating text files
tar -xf gawk-*.tar.xz -C /tmp/ \
  && mv /tmp/gawk-* /tmp/gawk \
  && pushd /tmp/gawk \
  && ./configure --prefix=/tools \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make check || true; fi \
  && make install \
  && popd \
  && rm -rf /tmp/gawk
