#!/bin/bash
set -e
echo "Building Util-linux.."
echo "Approximate build time: 1.0 SBU"
echo "Required disk space: 189 MB"

# 6.73. The Util-linux package contains miscellaneous utility programs. Among
# them are utilities for handling file systems, consoles, partitions, and messages
tar -xf /sources/util-linux-*.tar.xz -C /tmp/ \
  && mv /tmp/util-linux-* /tmp/util-linux \
  && pushd /tmp/util-linux

mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --docdir=/usr/share/doc/util-linux-2.31.1     \
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

echo "Util-linux test skipped due to warning."
#if [ $LFS_TEST -eq 1 ]
#    then
#    chown -Rv nobody .
#    su nobody -s /bin/bash -c "PATH=$PATH make -k check"
#fi

# install
make install
# cleanup
popd \
  && rm -rf /tmp/util-linux
