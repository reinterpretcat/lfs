#!/bin/bash
set -e
echo "Building Util-linux.."
echo "Approximate build time: 0.9 SBU"
echo "Required disk space: 131 MB"

# 5.34. Util-linux package contains miscellaneous utility programs
tar -xf util-linux-*.tar.xz -C /tmp/ \
  && mv /tmp/util-linux-* /tmp/util-linux \
  && pushd /tmp/util-linux \
  && ./configure --prefix=/tools    \
     --without-python               \
     --disable-makeinstall-chown    \
     --without-systemdsystemunitdir \
     --without-ncurses              \
     PKG_CONFIG=""                  \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/util-linux
