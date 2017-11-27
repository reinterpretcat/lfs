#!/bin/bash
set -e
echo "Building Linux API headers.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 865 MB"

# 6.7. Linux API Headers package exposes the kernel API for use by Glib
tar -xf sources/linux-*.tar.xz -C /tmp/ \
  && mv /tmp/linux-* /tmp/linux \
  && pushd /tmp/linux \
  && make mrproper \
  && make INSTALL_HDR_PATH=dest headers_install \
  && find dest/include \( -name .install -o -name ..install.cmd \) -delete \
  && cp -rv dest/include/* /usr/include \
  && popd \
  && rm -rf /tmp/linux
