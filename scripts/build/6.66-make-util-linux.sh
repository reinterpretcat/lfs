#!/bin/bash
set -e
echo "Building util-linux.."
echo "Approximate build time: 1.0 SBU"
echo "Required disk space: 181 MB"

# 6.66. Util-linux package contains miscellaneous utility programs. Among them
# are utilities for handling file systems, consoles, partitions, and messages
tar -xf /sources/util-linux-*.tar.xz -C /tmp/ \
  && mv /tmp/util-linux-* /tmp/util-linux \
  && pushd /tmp/util-linux

mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --docdir=/usr/share/doc/util-linux-2.30.1     \
    --disable-chfn-chsh                           \
    --disable-login                               \
    --disable-nologin                             \
    --disable-su                                  \
    --disable-setpriv                             \
    --disable-runuser                             \
    --disable-pylibmount                          \
    --disable-static                              \
    --without-python                              \
    --without-systemd                             \
    --without-systemdsystemunitdir
make
# NOTE skip tests due to warning
# install
make install
# cleanup
popd \
  && rm -rf /tmp/util-linux
