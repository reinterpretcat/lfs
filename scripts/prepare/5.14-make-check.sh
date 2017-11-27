#!/bin/bash
set -e
echo "Building check.."
echo "Approximate build time:  0.1 SBU"
echo "Required disk space: 11 MB"

# 5.14. Check is a unit testing framework for C
tar -xf check-*.tar.gz -C /tmp/ \
  && mv /tmp/check-* /tmp/check \
  && pushd /tmp/check \
  && PKG_CONFIG= ./configure --prefix=/tools \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make check; fi \
  && make install \
  && popd \
  && rm -rf /tmp/check
