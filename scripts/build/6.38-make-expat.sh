#!/bin/bash
set -e
echo "Building expat.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 9.5 MB"

# 6.38. Expat package contains a stream oriented C library for parsing XML
tar -xf expat-*.tar.bz2 -C /tmp/ \
  && mv /tmp/expat-* /tmp/expat \
  && pushd /tmp/expat
# fix a problem with the regession tests in the LFS environment
sed -i 's|usr/bin/env |bin/|' run.sh.in
# prepare for compilation
./configure --prefix=/usr --disable-static
# compile and install
make
make check
make install
# install docs
install -v -dm755 /usr/share/doc/expat-2.2.3
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.3
popd \
  && rm -rf /tmp/expat
