#!/bin/bash
set -e
echo "Building bzip2.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 5.2 MB"

# 5.18. Bzip2 package contains programs for compressing and decompressing files.
# Compressing text files with bzip2 yields a much better compression percentage
# than with the traditional gzip
tar -xf bzip2-*.tar.gz -C /tmp/ \
  && mv /tmp/bzip2-* /tmp/bzip2 \
  && pushd /tmp/bzip2 \
  && make \
  && make PREFIX=/tools install \
  && popd \
  && rm -rf /tmp/bzip2
