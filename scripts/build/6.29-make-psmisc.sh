#!/bin/bash
set -e
echo "Building psmisc.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 4.2 MB"

# 6.29. Psmisc package contains programs for displaying information
# about running processes
tar -xf /sources/psmisc-*.tar.xz -C /tmp/ \
  && mv /tmp/psmisc-* /tmp/psmisc \
  && pushd /tmp/psmisc
./configure --prefix=/usr
make
make install
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin
# cleanup
popd \
  && rm -rf /tmp/psmisc
