#!/bin/bash
set -e
echo "Building Linux API Headers.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 861 MB"

# 5.6.  Linux API Headers expose the kernel's API for use by Glibc
tar -xf linux-*.tar.xz -C /tmp/ \
  && mv /tmp/linux-* /tmp/linux \
  && pushd /tmp/linux \
  && make mrproper \
  && make INSTALL_HDR_PATH=dest headers_install \
  && cp -rv dest/include/* /tools/include \
  && popd \
  && rm -rf /tmp/linux
