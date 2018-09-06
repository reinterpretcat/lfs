#!/bin/bash
set -e
echo "Building gperf.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 5.9 MB"

# 6.37. Gperf generates a perfect hash function from a key set
tar -xf /sources/gperf-*.tar.gz -C /tmp/ \
  && mv /tmp/gperf-* /tmp/gperf \
  && pushd /tmp/gperf
# prepare
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
# compile and install
make
if [ $LFS_TEST -eq 1 ]; then make -j1 check; fi
make install
# cleanup
popd \
  && rm -rf /tmp/gperf
