#!/bin/bash
set -e
echo "Building gmp.."
echo "Approximate build time: 1.2 SBU"
echo "Required disk space: 59 MB"

# 6.17. GMP package contains math libraries
tar -xf sources/gmp-*.tar.xz -C /tmp/ \
  && mv /tmp/gmp-* /tmp/gmp \
  && pushd /tmp/gmp \
  && ./configure --prefix=/usr \
        --enable-cxx \
        --disable-static \
        --docdir=/usr/share/doc/gmp-6.1.2 \
  && make \
  && make html \
  && make check 2>&1 | tee gmp-check-log
# ensure that all tests passed (manual)
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
# continue with installation
make install \
  && make install-html \
  && popd \
  && rm -rf /tmp/gmp
