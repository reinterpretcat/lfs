#!/bin/bash
set -e
echo "Building make.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 13 MB"

# 5.28. The Make package contains a program for compiling packages.
tar -xf make-*.tar.bz2 -C /tmp/ \
 && mv /tmp/make-* /tmp/make \
 && pushd /tmp/make

# First, work around an error caused by glibc-2.27:
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c

# Prepare Make for compilation:
./configure --prefix=/tools --without-guile

# Compile the package:
make

# To run the Make test suite anyway, issue the following command:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package:
make install

# Cleanup
popd \
 && rm -rf /tmp/make
