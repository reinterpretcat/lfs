#!/bin/bash
set -e
echo "Building bison.."
echo "Approximate build time:  0.3 SBU"
echo "Required disk space: 32 MB"

# 5.17. Bison package contains a parser generator
tar -xf bison-*.tar.xz -C /tmp/ \
  && mv /tmp/bison-* /tmp/bison \
  && pushd /tmp/bison \
  && ./configure --prefix=/tools \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/bison
