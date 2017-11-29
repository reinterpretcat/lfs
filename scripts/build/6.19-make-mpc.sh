#!/bin/bash
set -e
echo "Building mpc.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 17 MB"

# 6.19. MPC package contains a library for the arithmetic of complex
# numbers with arbitrarily high precision and correct rounding of the result
tar -xf /sources/mpc-*.tar.gz -C /tmp/ \
  && mv /tmp/mpc-* /tmp/mpc \
  && pushd /tmp/mpc \
  && ./configure --prefix=/usr \
        --disable-static \
        --docdir=/usr/share/doc/mpc-3.1.5 \
  && make \
  && make html \
  && if [ $LFS_TEST -eq 1 ]; then make check; fi \
  && make install \
  && make install-html \
  && popd \
  && rm -rf /tmp/mpc
