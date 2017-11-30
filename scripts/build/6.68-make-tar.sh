#!/bin/bash
set -e
echo "Building tar.."
echo "Approximate build time: 2.6 SBU"
echo "Required disk space: 29 MB"

# 6.68. Tar package contains an archiving program
tar -xf /sources/tar-*.tar.xz -C /tmp/ \
  && mv /tmp/tar-* /tmp/tar \
  && pushd /tmp/tar

FORCE_UNSAFE_CONFIGURE=1    \
  ./configure --prefix=/usr \
              --bindir=/bin
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.29
# cleanup
popd \
  && rm -rf /tmp/tar
