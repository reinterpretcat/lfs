#!/bin/bash
set -e
echo "Building Coreutils.."
echo "Approximate build time: 0.7 SBU"
echo "Required disk space: 139 MB"

# 5.19. The Coreutils package contains utilities for showing and
# setting the basic system characteristics.

# NOTE: has failed tests
# NOTE: has workaround for deletion directories with long name

tar -xf coreutils-*.tar.xz -C /tmp/ \
  && mv /tmp/coreutils-* /tmp/coreutils \
  && pushd /tmp/coreutils

# Prepare Coreutils for compilation:
./configure --prefix=/tools --enable-install-program=hostname

# Compile the package:
make

# To run the Coreutils test suite anyway, issue the following command:
if [ $LFS_TEST -eq 1 ]; then make RUN_EXPENSIVE_TESTS=yes check || true; fi

# Install the package:
make install

# Cleanup
popd \
  && rm -rf /tmp/coreutils
