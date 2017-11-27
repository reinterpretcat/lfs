#!/bin/bash
set -e
echo "Building m4.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 19 MB"

# 5.27.  M4 package contains a macro processor
tar -xf m4-*.tar.xz -C /tmp/ \
  && mv /tmp/m4-* /tmp/m4 \
  && pushd /tmp/m4 \
  && ./configure --prefix=/tools \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make check; fi \
  && make install \
  && popd \
  && rm -rf /tmp/m4
