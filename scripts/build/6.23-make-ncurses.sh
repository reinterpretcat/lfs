#!/bin/bash
set -e
echo "Building ncurses.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 39 MB"

# 6.23. Ncurses package contains libraries for terminal-independent
# handling of character screens
tar -xf sources/ncurses-*.tar.gz -C /tmp/ \
  && mv /tmp/ncurses-* /tmp/ncurses \
  && pushd /tmp/ncurses \
./configure --prefix=/usr \
    --mandir=/usr/share/man \
    --with-shared     \
    --without-debug   \
    --without-normal  \
    --enable-pc-files \
    --enable-widec    \
  && make \
  && make install
# move the shared libraries to the /lib directory,
mv -v /usr/lib/libncursesw.so.6* /lib
# recreate symlink
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
# link with wide-character libraries
for lib in ncurses form panel menu ; do
  rm -vf                      /usr/lib/lib${lib}.so
  echo "INPUT(-l${lib}w)" >   /usr/lib/lib${lib}.so
  ln -sfv ${lib}w.pc          /usr/lib/pkgconfig/${lib}.pc
done
# fix symlinks
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so
# install documentation
mkdir -v /usr/share/doc/ncurses-6.0
cp -v -R doc/* /usr/share/doc/ncurses-6.0
# cleanup
popd \
  && rm -rf /tmp/ncurses
