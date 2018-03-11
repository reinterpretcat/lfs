#!/bin/bash
set -e
echo "Building MPC.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 21 MB"

# 6.19. The MPC package contains a library for the arithmetic of
# complex numbers with arbitrarily high precision and correct
# rounding of the result.
tar -xf /sources/mpc-*.tar.gz -C /tmp/ \
  && mv /tmp/mpc-* /tmp/mpc \
  && pushd /tmp/mpc

# Prepare MPC for compilation:
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.1.0

# Compile the package and generate the HTML documentation:
make
make html

# To test the results, issue:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package and its documentation:
make install
if [ $LFS_DOCS -eq 1 ]; then make install-html; fi

popd \
  && rm -rf /tmp/mpc
