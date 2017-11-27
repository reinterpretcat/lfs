#!/bin/bash
set -e
echo "Building ncurses.."
echo "Approximate build time:  0.5 SBU"
echo "Required disk space: 38 MB"

# 5.15. Ncurses package contains libraries for terminal-independent
# handling of character screens
tar -xf ncurses-*.tar.gz -C /tmp/ \
  && mv /tmp/ncurses-* /tmp/ncurses \
  && pushd /tmp/ncurses \
  && sed -i s/mawk// configure \
  && ./configure          \
      --prefix=/tools    \
      --with-shared      \
      --without-debug    \
      --without-ada      \
      --enable-widec     \
      --enable-overwrite \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/ncurses
