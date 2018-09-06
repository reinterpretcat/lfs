#!/bin/bash
set -e
echo "Building Libffi.."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 7.6 MB"

# 6.49. The Libffi library provides a portable, high level programming
# interface to various calling conventions. This allows a programmer
# to call any function specified by a call interface description at
# run time.
tar -xf /sources/libffi-*.tar.xz -C /tmp/ \
  && mv /tmp/libffi-* /tmp/libffi \
  && pushd /tmp/libffi
# Modify the Makefile to install headers into the standard /usr/include directory instead of /usr/lib/libffi-3.2.1/include.
sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
    -i include/Makefile.in
sed -e '/^includedir/ s/=.*$/=@includedir@/' \
    -e 's/^Cflags: -I${includedir}/Cflags:/' \
    -i libffi.pc.in
# prepare for compilation
./configure --prefix=/usr --disable-static
# compile, test and install
make
# run tests
if [ $LFS_TEST -eq 1 ]; then make check || true; fi
make install
# cleanup
popd \
  && rm -rf /tmp/libffi
