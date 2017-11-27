#!/bin/bash
set -e
echo "Building make.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 12.5 MB"

# 5.28. Make package contains a program for compiling packages
tar -xf make-*.tar.bz2 -C /tmp/ \
 && mv /tmp/make-* /tmp/make \
 && pushd /tmp/make \
 && ./configure --prefix=/tools --without-guile \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/make
