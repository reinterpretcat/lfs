#!/bin/bash
set -e
echo "Building LFS-Bootscripts.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 244 KB"

# 7.2. LFS-Bootscripts package contains a set of scripts to start/stop
# the LFS system at bootup/shutdown
tar -xf /sources/lfs-bootscripts-*.tar.bz2 -C /tmp/ \
  && mv /tmp/lfs-bootscripts-* /tmp/lfs-bootscripts \
  && pushd /tmp/lfs-bootscripts

make install

# cleanup
popd \
  && rm -rf /tmp/lfs-bootscripts
