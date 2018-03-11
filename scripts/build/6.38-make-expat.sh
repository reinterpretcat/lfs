#!/bin/bash
set -e
echo "Building Expat.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 11 MB"

# 6.38. The Expat package contains a stream oriented C library for
# parsing XML.
tar -xf /sources/expat-*.tar.bz2 -C /tmp/ \
  && mv /tmp/expat-* /tmp/expat \
  && pushd /tmp/expat

# First fix a problem with the regession tests in the LFS environment
sed -i 's|usr/bin/env |bin/|' run.sh.in

# Prepare Expat for compilation:
./configure --prefix=/usr --disable-static

# Compile the package:
make

# To test the results, issue:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package:
make install

# If desired, install the documentation:
if [ $LFS_DOCS -eq 1 ]; then
  install -v -dm755 /usr/share/doc/expat-2.2.5
  install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.5
fi

# Cleanup
popd \
  && rm -rf /tmp/expat
