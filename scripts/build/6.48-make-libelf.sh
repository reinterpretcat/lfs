#!/bin/bash
set -e
echo "Building Libelf.."
echo "Approximate build time: 0.6 SBU"
echo "Required disk space: 74 MB"

# 6.48. Libelf is a library for handling ELF (Executable and Linkable
# Format) files.
tar -xf /sources/elfutils-*.tar.bz2 -C /tmp/ \
  && mv /tmp/elfutils-* /tmp/elfutils \
  && pushd /tmp/elfutils
# prepare for compilation
./configure --prefix=/usr
# compile, test and install
make
# run tests
if [ $LFS_TEST -eq 1 ]; then make check || true; fi
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
# cleanup
popd \
  && rm -rf /tmp/elfutils
