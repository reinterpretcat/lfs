#!/bin/bash
set -e
echo "Building kbd.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 29 MB"

# 6.66. Kbd package contains key-table files, console fonts, and
# keyboard utilities
tar -xf /sources/kbd-*.tar.xz -C /tmp/ \
  && mv /tmp/kbd-* /tmp/kbd \
  && pushd /tmp/kbd
# fixes an issue for i386 keymaps
patch -Np1 -i /sources/kbd-2.0.4-backspace-1.patch
# remove the redundant resizecons program
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
# prepare
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
# compile, test and install
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
# install docs
if [ $LFS_DOCS -eq 1 ]; then
  mkdir -v /usr/share/doc/kbd-2.0.4
  cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.4
fi
# cleanup
popd \
  && rm -rf /tmp/kbd
