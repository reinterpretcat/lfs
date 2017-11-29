#!/bin/bash
set -e
echo "Building man pages.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 27 MB"

# 6.8. Man-pages package describes C programming language functions,
# important device files, and significant configuration files
tar -xf /sources/man-pages-*.tar.xz -C /tmp/ \
  && mv /tmp/man-pages-* /tmp/man-pages \
  && pushd /tmp/man-pages \
  && make install \
  && popd \
  && rm -rf /tmp/man-pages
