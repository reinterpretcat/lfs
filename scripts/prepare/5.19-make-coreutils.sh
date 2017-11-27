#!/bin/bash
set -e
echo "Building coreutils.."
echo "Approximate build time: 0.6 SBU"
echo "Required disk space: 136 MB"

# 5.19. Coreutils package contains utilities for showing and setting
# the basic system characteristics
# NOTE: has failed tests
# NOTE: has workaround for deletion directiories with long name
tar -xf coreutils-*.tar.xz -C /tmp/ \
  && mv /tmp/coreutils-* /tmp/coreutils \
  && pushd /tmp/coreutils \
  && ./configure --prefix=/tools --enable-install-program=hostname \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make RUN_EXPENSIVE_TESTS=yes check || true; fi \
  && make install \
  && popd \
  && rm -rf /tmp/coreutils || true
