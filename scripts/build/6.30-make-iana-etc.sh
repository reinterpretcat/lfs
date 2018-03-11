#!/bin/bash
set -e
echo "Building Iana-Etc.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 2.3 MB"

# 6.30. Iana-Etc package provides data for network services and protocols
tar -xf /sources/iana-etc-*.tar.bz2 -C /tmp/ \
  && mv /tmp/iana-etc-* /tmp/iana-etc \
  && pushd /tmp/iana-etc

make
make install
# cleanup
popd \
  && rm -rf /tmp/iana-etc
