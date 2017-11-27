#!/bin/bash
set -e
echo "Building sed.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 16 MB"

# 5.31. Sed package contains a stream editor
tar -xf sed-*.tar.xz -C /tmp/ \
  && mv /tmp/sed-* /tmp/sed \
  && pushd /tmp/sed \
  && ./configure --prefix=/tools \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make check || true; fi \
  && make install \
  && popd \
  && rm -rf /tmp/sed
