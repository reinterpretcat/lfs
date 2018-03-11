#!/bin/bash
set -e
echo "Building Meson.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 16 MB"

# 6.51. Meson is an open source build system meant to be both extremely fast,
# and, even more importantly, as user friendly as possible.
tar -xf /sources/meson-*.tar.gz -C /tmp/ \
  && mv /tmp/meson-* /tmp/meson \
  && pushd /tmp/meson

# Build
python3 setup.py build

# Install package
python3 setup.py install

# cleanup
popd \
  && rm -rf /tmp/meson
