#!/bin/bash
set -e
echo "Building mpfr.."
echo "Approximate build time: 0.8 SBU"
echo "Required disk space: 45 MB"

# 6.18. MPFR package contains functions for multiple precision math
tar -xf /sources/mpfr-*.tar.xz -C /tmp/ \
  && mv /tmp/mpfr-* /tmp/mpfr \
  && pushd /tmp/mpfr

./configure --prefix=/usr  \
    --disable-static     \
    --enable-thread-safe \
    --docdir=/usr/share/doc/mpfr-3.1.5
make
make html
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
if [ $LFS_DOCS -eq 1 ]; then make install-html; fi

popd \
  && rm -rf /tmp/mpfr
