#!/bin/bash
set -e
echo "Building make.."
echo "Approximate build time: 0.6 SBU"
echo "Required disk space: 12 MB"

# 6.68. Make package contains a program for compiling packages
tar -xf /sources/make-*.tar.bz2 -C /tmp/ \
  && mv /tmp/make-* /tmp/make \
  && pushd /tmp/make

# Again, work around an error caused by glibc-2.27
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c

# Configure
./configure --prefix=/usr

# Build
make

# Run tests
if [ $LFS_TEST -eq 1 ]; then make PERL5LIB=$PWD/tests/ check; fi

# Install
make install

# cleanup
popd \
  && rm -rf /tmp/make
