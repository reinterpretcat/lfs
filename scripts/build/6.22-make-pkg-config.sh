#!/bin/bash
set -e
echo "Building pkg config.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 28 MB"

# 6.22. Pkg-config package contains a tool for passing the include path
# and/or library paths to build tools during the configure and make file execution
tar -xf /sources/pkg-config-*.tar.gz -C /tmp/ \
  && mv /tmp/pkg-config-* /tmp/pkg-config \
  && pushd /tmp/pkg-config \
  && ./configure --prefix=/usr \
      --with-internal-glib \
      --disable-host-tool  \
      --docdir=/usr/share/doc/pkg-config-0.29.2 \
  && make \
  && make check \
  && make install \
  && popd \
  && rm -rf /tmp/pkg-config
