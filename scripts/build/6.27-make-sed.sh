#!/bin/bash
set -e
echo "Building Sed.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 26 MB"

# 6.27. Sed package contains a stream editor
tar -xf /sources/sed-*.tar.xz -C /tmp/ \
  && mv /tmp/sed-* /tmp/sed \
  && pushd /tmp/sed

# First fix an issue in the LFS environment and remove a failing test:
sed -i 's/usr/tools/'                 build-aux/help2man
sed -i 's/testsuite.panic-tests.sh//' Makefile.in

# Prepare Sed for compilation:
./configure --prefix=/usr --bindir=/bin

# Compile the package and generate the HTML documentation:
make
make html

# To test the results, issue:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package and its documentation:
make install
if [ $LFS_DOCS -eq 1 ]; then
  install -d -m755           /usr/share/doc/sed-4.4
  install -m644 doc/sed.html /usr/share/doc/sed-4.4
fi

# Cleanup
popd \
  && rm -rf /tmp/sed
