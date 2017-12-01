#!/bin/bash
set -e
echo "Building procps-ng.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 14 MB"

# 6.48. Procps-ng package contains programs for monitoring processes
tar -xf /sources/procps-ng-*.tar.xz -C /tmp/ \
  && mv /tmp/procps-ng-* /tmp/procps-ng \
  && pushd /tmp/procps-ng
# prepare for compilation
./configure --prefix=/usr                   \
  --exec-prefix=                            \
  --libdir=/usr/lib                         \
  --docdir=/usr/share/doc/procps-ng-3.3.12  \
  --disable-static                          \
  --disable-kill
# compile, test and install
make
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
sed -i '/set tty/d'                   testsuite/pkill.test/pkill.exp
rm testsuite/pgrep.test/pgrep.exp
# ps test may fa
if [ $LFS_TEST -eq 1 ]; then make check || true; fi
make install
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
# cleanup
popd \
  && rm -rf /tmp/procps-ng
