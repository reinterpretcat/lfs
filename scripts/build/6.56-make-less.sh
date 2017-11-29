#!/bin/bash
set -e
echo "Building less.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 3.5 MB"

# 6.56. Less package contains a text file viewer
tar -xf /sources/less-*.tar.gz -C /tmp/ \
  && mv /tmp/less-* /tmp/less \
  && pushd /tmp/less

./configure --prefix=/usr --sysconfdir=/etc
make
make install
# cleanup
popd \
  && rm -rf /tmp/less
