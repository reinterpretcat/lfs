#!/bin/bash
set -e
echo "Building automake.."
echo "Approximate build time: SBU"
echo "Required disk space:  MB"

# 6.44. Automake package contains programs for generating Makefiles
# for use with Autoconf
tar -xf /sources/automake-*.tar.xz -C /tmp/ \
  && mv /tmp/automake-* /tmp/automake \
  && pushd /tmp/automake
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15.1
make
sed -i "s:./configure:LEXLIB=/usr/lib/libfl.a &:" t/lex-{clean,depend}-cxx.sh
if [ $LFS_TEST -eq 1 ]; then make -j4 check || true; fi
make install
# cleanup
popd \
  && rm -rf /tmp/automake
