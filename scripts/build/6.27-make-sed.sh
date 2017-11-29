#!/bin/bash
set -e
echo "Building sed.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 25 MB"

# 6.27. Sed package contains a stream editor
tar -xf /sources/sed-*.tar.xz -C /tmp/ \
  && mv /tmp/sed-* /tmp/sed \
  && pushd /tmp/sed
# fix an issue in the LFS environment and remove a failing test
sed -i 's/usr/tools/'                 build-aux/help2man
sed -i 's/testsuite.panic-tests.sh//' Makefile.in
# prepare for compilation
./configure --prefix=/usr --bindir=/bin
make
make html
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
install -d -m755           /usr/share/doc/sed-4.4
install -m644 doc/sed.html /usr/share/doc/sed-4.4
# cleanup
popd \
  && rm -rf /tmp/sed
