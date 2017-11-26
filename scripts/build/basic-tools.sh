#!/bin/bash

# compile Linux API headers which expose the kernel API for use by Glib
tar -xf sources/linux-*.tar.xz -C /tmp/ \
  && mv /tmp/linux-* /tmp/linux \
  && pushd /tmp/linux \
  && make mrproper \
  && make INSTALL_HDR_PATH=dest headers_install \
  && find dest/include \( -name .install -o -name ..install.cmd \) -delete \
  && cp -rv dest/include/* /usr/include \
  && popd \
  && rm -rf /tmp/linux

# compile man-pages package which describe C programming language functions,
# important device files, and significant configuration files
tar -xf sources/man-pages-*.tar.xz -C /tmp/ \
  && mv /tmp/man-pages-* /tmp/man-pages \
  && pushd /tmp/man-pages \
  && make install \
  && popd \
  && rm -rf /tmp/man-pages

# compile Glibc package which contains the main C library
tar -xf sources/glibc-*.tar.xz -C /tmp/ \
 && mv /tmp/glibc-* /tmp/glibc \
 && pushd /tmp/glibc \
 && patch -Np1 -i ../glibc-2.26-fhs-1.patch \
 && ln -sfv /tools/lib/gcc /usr/lib
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
make check || true
# prevent warning during install
touch /etc/ld.so.conf
# fix the generated Makefile to skip an uneeded sanity check that fails in the LFS partial environmen
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

# configure Glibc
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

# install and set up the time zone data
# tar -xf /tools/sources/tzdata2017b.tar.gz
# ZONEINFO=/usr/share/zoneinfo
# mkdir -pv $ZONEINFO/{posix,right}
# for tz in etcetera southamerica northamerica europe africa antarctica \
#           asia australasia backward pacificnew systemv; do
#     zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
#     zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
#     zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
# done
#
# cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
# zic -d $ZONEINFO -p America/New_York
# unset ZONEINFO
