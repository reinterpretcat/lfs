#!/bin/bash
set -e
echo "Building DejaGNU.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 3.2 MB"

# 5.13. DejaGNU package contains a framework for testing other programs
tar -xf dejagnu-*.tar.gz -C /tmp/ \
  && mv /tmp/dejagnu-* /tmp/dejagnu \
  && pushd /tmp/dejagnu \
  && ./configure --prefix=/tools \
  && make install \
  && if [ $LFS_TEST -eq 1 ]; then make check; fi \
  && popd \
  && rm -rf /tmp/dejagnu
