#!/bin/bash
set -e
echo "Building iproute2.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 12 MB"

# 6.58. IPRoute2 package contains programs for basic and advanced
# IPV4-based networki
tar -xf /sources/iproute2-*.tar.xz -C /tmp/ \
  && mv /tmp/iproute2-* /tmp/iproute2 \
  && pushd /tmp/iproute2

sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
rm -v doc/arpd.sgml
sed -i 's/m_ipt.o//' tc/Makefile
make
make DOCDIR=/usr/share/doc/iproute2-4.12.0 install
# cleanup
popd \
  && rm -rf /tmp/iproute2
