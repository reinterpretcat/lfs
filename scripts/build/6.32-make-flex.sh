#!/bin/bash
set -e
echo "Building flex.."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 32 MB"

# 6.32. Flex package contains a utility for generating programs
# that recognize patterns in text
tar -xf /sources/flex-*.tar.gz -C /tmp/ \
  && mv /tmp/flex-* /tmp/flex \
  && pushd /tmp/flex
# fix a problem introduced with glibc-2.26
sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
# prepare for compilation
HELP2MAN=/tools/bin/true \
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4
# compile and install
make
make check
make install
ln -sv flex /usr/bin/lex
# cleanup
popd \
  && rm -rf /tmp/flex
