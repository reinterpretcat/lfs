#!/bin/bash
echo "Build toolchain.."


# 6.7. Linux API Headers package exposes the kernel API for use by Glib
tar -xf sources/linux-*.tar.xz -C /tmp/ \
  && mv /tmp/linux-* /tmp/linux \
  && pushd /tmp/linux \
  && make mrproper \
  && make INSTALL_HDR_PATH=dest headers_install \
  && find dest/include \( -name .install -o -name ..install.cmd \) -delete \
  && cp -rv dest/include/* /usr/include \
  && popd \
  && rm -rf /tmp/linux


# 6.8. Man-pages package describes C programming language functions,
# important device files, and significant configuration files
tar -xf sources/man-pages-*.tar.xz -C /tmp/ \
  && mv /tmp/man-pages-* /tmp/man-pages \
  && pushd /tmp/man-pages \
  && make install \
  && popd \
  && rm -rf /tmp/man-pages


# 6.9. Glibc package contains the main C library
tar -xf sources/glibc-*.tar.xz -C /tmp/ \
 && mv /tmp/glibc-* /tmp/glibc \
 && pushd /tmp/glibc
# 6.9.1. Installation of Glibc
patch -Np1 -i /sources/glibc-2.26-fhs-1.patch \
ln -sfv /tools/lib/gcc /usr/lib
case $(uname -m) in
 i?86)   GCC_INCDIR=/usr/lib/gcc/$(uname -m)-pc-linux-gnu/7.2.0/include
         ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
 ;;
 x86_64) GCC_INCDIR=/usr/lib/gcc/x86_64-pc-linux-gnu/7.2.0/include
         ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
         ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
 ;;
esac
# remove a file that may be left over from a previous build attempt
rm -f /usr/include/limits.h
# Glibc documentation recommends building Glibc in a dedicated build directory
mkdir -v build
cd build
# prepare Glibc for compilation:
CC="gcc -isystem $GCC_INCDIR -isystem /usr/include" \
../configure --prefix=/usr                          \
  --disable-werror                                  \
  --enable-kernel=3.2                               \
  --enable-stack-protector=strong                   \
  libc_cv_slibdir=/lib
unset GCC_INCDIR
make
#make check || true
# prevent warning during install
touch /etc/ld.so.conf
# fix the generated Makefile to skip an uneeded sanity check that fails in the LFS partial environment
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
# install the package:
make install
# install the configuration file and runtime directory for nscd
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
# install the systemd support files for nscd
install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service
# install the locales that can make the system respond in a different language
mkdir -pv /usr/lib/locale
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
# cleanup
popd
rm -rf /tmp/glibc

# 6.9.2. Configuring Glibc
# 6.9.2.1. Adding nsswitch.conf
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF

# 6.9.2.2. Adding time zone data
mkdir /tmp/tzdata \
  && tar -xf /sources/tzdata2017b.tar.gz -C /tmp/tzdata \
  && pushd /tmp/tzdata

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
popd && rm -rf /tmp/tzdata
# set time zone info
ln -sfv /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# 6.9.2.3. Configuring the Dynamic Loader
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
mkdir -pv /etc/ld.so.conf.d


# 6.10. Adjusting the Toolchain
# fix linker
mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld
# amend the GCC specs file so that it points to the new dynamic linker
gcc -dumpspecs | sed -e 's@/tools@@g'                 \
  -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
  -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
  `dirname $(gcc --print-libgcc-file-name)`/specs
# perform check
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
# additional checks (observe output manually)
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B1 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
# cleanup
rm -v dummy.c a.out dummy.log


# 6.11. Zlib package contains compression and decompression
# routines used by some programs
tar -xf sources/zlib-*.tar.xz -C /tmp/ \
  && mv /tmp/zlib-* /tmp/zlib \
  && pushd /tmp/zlib \
  && ./configure --prefix=/usr \
  && make \
  && make check \
  && make install \
  && mv -v /usr/lib/libz.so.* /lib \
  && ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so \
  && popd \
  && rm -rf /tmp/zlib


# 6.12. File package contains a utility for determining
# the type of a given file or files
tar -xf sources/file-*.tar.gz -C /tmp/ \
  && mv /tmp/file-* /tmp/file \
  && pushd /tmp/file \
  && ./configure --prefix=/usr \
  && make \
  && make check \
  && make install \
  && popd \
  && rm -rf /tmp/file


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


# 6.14. M4 package contains a macro processor
tar -xf sources/m4-*.tar.xz -C /tmp/ \
  && mv /tmp/m4-* /tmp/m4 \
  && pushd /tmp/m4 \
  && ./configure --prefix=/usr \
  && make \
  && make check \
  && make install \
  && popd \
  && rm -rf /tmp/m4

# 6.15. Bc package contains an arbitrary precision numeric processing language
tar -xf sources/bc-*.tar.gz -C /tmp/ \
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
  --infodir=/usr/share/info \
  && make \
  && echo "quit" | ./bc/bc -l Test/checklib.b \
  && make install \
  && popd \
  && rm -rf /tmp/bc
