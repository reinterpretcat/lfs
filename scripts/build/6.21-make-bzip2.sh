#!/bin/bash
set -e
echo "Building bzip2.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 2.3 MB"

# 6.21. Bzip2 package contains programs for compressing and decompressing files.
# Compressing text files with bzip2 yields a much better compression percentage
# than with the traditional gzip
tar -xf /sources/bzip2-*.tar.gz -C /tmp/ \
  && mv /tmp/bzip2-* /tmp/bzip2 \
  && pushd /tmp/bzip2
# apply a patch that will install the documentation for this package
patch -Np1 -i /sources/bzip2-1.0.6-install_docs-1.patch
# ensure the man pages are installed into the correct location
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
# prepare for compilation
make -f Makefile-libbz2_so
make clean
# compile
make
make PREFIX=/usr install
# install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

popd \
  && rm -rf /tmp/bzip2
