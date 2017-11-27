#!/bin/bash
set -e
echo "Building grep.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 19 MB"

# 5.25. Grep package contains programs for searching through files
tar -xf grep-*.tar.xz -C /tmp/ \
  && mv /tmp/grep-* /tmp/grep \
  && pushd /tmp/grep \
  && ./configure --prefix=/tools \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make check; fi \
  && make install \
  && popd \
  && rm -rf /tmp/grep
