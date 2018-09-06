#!/bin/bash
set -e
echo "Building gzip.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 10 MB"

# 5.26. Gzip package contains programs for compressing and decompressing files
tar -xf gzip-*.tar.xz -C /tmp/ \
  && mv /tmp/gzip-* /tmp/gzip \
  && pushd /tmp/gzip \
  && ./configure --prefix=/tools \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make check || true; fi \
  && make install \
  && popd \
  && rm -rf /tmp/gzip
