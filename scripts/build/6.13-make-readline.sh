#!/bin/bash
set -e
echo "Building readline.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 15 MB"

# 6.13. Readline package is a set of libraries that offers command-line
# editing and history capabilities
tar -xf sources/readline-*.tar.gz -C /tmp/ \
  && mv /tmp/readline-* /tmp/readline \
  && pushd /tmp/readline \
  && sed -i '/MV.*old/d' Makefile.in \
  && sed -i '/{OLDSUFF}/c:' support/shlib-install \
  && ./configure --prefix=/usr  \
      --disable-static \
      --docdir=/usr/share/doc/readline-7.0 \
  && make SHLIB_LIBS="-L/tools/lib -lncursesw" \
  && make SHLIB_LIBS="-L/tools/lib -lncurses" install \
  && mv -v /usr/lib/lib{readline,history}.so.* /lib \
  && ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so \
  && ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so \
  && install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-7.0 \
  && popd \
  && rm -rf /tmp/readline
