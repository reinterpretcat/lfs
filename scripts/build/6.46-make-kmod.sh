#!/bin/bash
set -e
echo "Building kmod.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 12 MB"

# 6.46. Kmod package contains libraries and utilities for loading kernel modules
tar -xf /sources/kmod-*.tar.xz -C /tmp/ \
  && mv /tmp/kmod-* /tmp/kmod \
  && pushd /tmp/kmod
./configure --prefix=/usr   \
    --bindir=/bin           \
    --sysconfdir=/etc       \
    --with-rootlibdir=/lib  \
    --with-xz               \
    --with-zlib
make
make install
# create symlinks for compatibility with Module-Init-Tools (the package that
# previously handled Linux kernel modules)
for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done
ln -sfv kmod /bin/lsmod
# cleanup
popd \
  && rm -rf /tmp/kmod
