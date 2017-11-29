#!/bin/bash
set -e
echo "Building libcap.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 1.3 MB"

# 6.26. Libcap package implements the user-space interfaces to the POSIX 1003.1e
# capabilities available in Linux kernels. These capabilities are a partitioning
# of the all powerful root privilege into a set of distinct privileges
tar -xf /sources/libcap-*.tar.xz -C /tmp/ \
  && mv /tmp/libcap-* /tmp/libcap \
  && pushd /tmp/libcap
# prevent a static library from being installed
sed -i '/install.*STALIBNAME/d' libcap/Makefile
# compile
make
# install
make RAISE_SETFCAP=no lib=lib prefix=/usr install
chmod -v 755 /usr/lib/libcap.so
mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so
# cleanup
popd \
  && rm -rf /tmp/libcap
