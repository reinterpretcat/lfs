#!/bin/bash
set -e
echo "Building mpc.."
echo "Approximate build time: 82 SBU"
echo "Required disk space: 3.2 GB"

# 6.20. GCC package contains the GNU compiler collection, which
# includes the C and C++ compilers
tar -xf /sources/gcc-*.tar.xz -C /tmp/ \
  && mv /tmp/gcc-* /tmp/gcc \
  && pushd /tmp/gcc
# change the default directory name for 64-bit libraries to “lib”
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
  ;;
esac
# remove the symlink created earlier as the final gcc includes will be installed here
rm -f /usr/lib/gcc
# create build directory
mkdir -v build && cd build
# prepare for compilation
SED=sed                      \
../configure --prefix=/usr   \
    --enable-languages=c,c++ \
    --disable-multilib       \
    --disable-bootstrap      \
    --with-system-zlib
# compile package
make
# increase the stack size prior to running the tests
ulimit -s 32768
# test the results, but do not stop at errors
if [ $LFS_TEST -eq 1 ]; then make -k check || true; fi
# check resualts (manual)
../contrib/test_summary | grep -A7 Summ
# install
make install
# make symlinks
ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
# add a compatibility symlink to enable building programs with
# Link Time Optimization (LTO)
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/7.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
# perform sanity checks (as above)
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
# cleanup
rm -v dummy.c a.out dummy.log
# move a misplaced file
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
popd \
  && rm -rf /tmp/gcc
