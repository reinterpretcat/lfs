#!/bin/bash
set -e
echo "Building sysvinit.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 1.1 MB"

# 6.64. Sysvinit package contains programs for controlling the startup,
# running, and shutdown of the system
tar -xf /sources/sysvinit-*.tar.bz2 -C /tmp/ \
  && mv /tmp/sysvinit-* /tmp/sysvinit \
  && pushd /tmp/sysvinit
# apply a patch that removes several programs installed by other packages,
# clarifies a message, and fixes a compiler warning
patch -Np1 -i /sources/sysvinit-2.88dsf-consolidated-1.patch
# compile and install
make -C src
make -C src install
# cleanup
popd \
  && rm -rf /tmp/sysvinit
