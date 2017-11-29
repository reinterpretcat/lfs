#!/bin/bash
set -e
echo "Building make.."
echo "Approximate build time: 0.6 SBU"
echo "Required disk space: 12.6 MB"

# 6.61. Make package contains a program for compiling packages
tar -xf /sources/make-*.tar.bz2 -C /tmp/ \
  && mv /tmp/make-* /tmp/make \
  && pushd /tmp/make

./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make PERL5LIB=$PWD/tests/ check; fi
make install
# cleanup
popd \
  && rm -rf /tmp/make
