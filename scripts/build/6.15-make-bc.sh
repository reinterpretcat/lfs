#!/bin/bash
set -e
echo "Building bc.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 3.6 MB"

# 6.15. Bc package contains an arbitrary precision numeric processing language
tar -xf /sources/bc-*.tar.gz -C /tmp/ \
  && mv /tmp/bc-* /tmp/bc \
  && pushd /tmp/bc
# use sed instead of ed
cat > bc/fix-libmath_h << "EOF"
#! /bin/bash
sed -e '1 s/^/{"/'  \
    -e 's/$/",/'    \
    -e '2,$ s/^/"/' \
    -e '$ d'        \
    -i libmath.h
sed -e '$ s/$/0}/' \
    -i libmath.h
EOF
# create temporary symbolic links so the package can find the readline library
ln -sv /tools/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
ln -sfv libncurses.so.6 /usr/lib/libncurses.so
# fix an issue in configure due to missing files in the early stages of LFS
sed -i -e '/flex/s/as_fn_error/: ;; # &/' configure
# build
./configure --prefix=/usr   \
  --with-readline           \
  --mandir=/usr/share/man   \
  --infodir=/usr/share/info
make
echo "quit" | ./bc/bc -l Test/checklib.b
make install

popd \
  && rm -rf /tmp/bc
