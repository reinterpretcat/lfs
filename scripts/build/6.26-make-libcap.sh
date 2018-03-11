#!/bin/bash
set -e
echo "Building Libcap.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 1.3 MB"

# 6.26. The Libcap package implements the user-space interfaces to the
# POSIX 1003.1e capabilities available in Linux kernels. These
# capabilities are a partitioning of the all powerful root privilege
# into a set of distinct privileges
tar -xf /sources/libcap-*.tar.xz -C /tmp/ \
  && mv /tmp/libcap-* /tmp/libcap \
  && pushd /tmp/libcap

# Prevent a static library from being installed:
sed -i '/install.*STALIBNAME/d' libcap/Makefile

# Compile the package:
make

# Install the package:
make RAISE_SETFCAP=no lib=lib prefix=/usr install
chmod -v 755 /usr/lib/libcap.so

# The shared library needs to be moved to /lib, and as a result the
# .so file in /usr/lib will need to be recreated:
mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so

# Cleanup
popd \
  && rm -rf /tmp/libcap
