#!/bin/bash
set -e
echo "Building GCC.."
echo "Approximate build time: 81 SBU (with tests)"
echo "Required disk space: 3.1 GB"

# 6.20. GCC package contains the GNU compiler collection, which
# includes the C and C++ compilers
tar -xf /sources/gcc-*.tar.xz -C /tmp/ \
  && mv /tmp/gcc-* /tmp/gcc \
  && pushd /tmp/gcc

# If building on x86_64, change the default directory name for
# 64-bit libraries to “lib”:
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

# Remove the symlink created earlier as the final gcc includes will
# be installed here
rm -f /usr/lib/gcc

# The GCC documentation recommends building GCC in a dedicated
# build directory:
mkdir -v build
cd       build

# prepare for compilation
SED=sed                               \
../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib

# Compile the package:
make

# One set of tests in the GCC test suite is known to exhaust the
# stack, so increase the stack size prior to running the tests:
ulimit -s 32768

# Test the results, but do not stop at errors:
if [ $LFS_TEST -eq 1 ]; then
   make -k check || true
   # To receive a summary of the test suite results, run:
   ../contrib/test_summary | grep -A7 Summ
fi

# Install the package:
make install

# Create a symlink required by the FHS for "historical" reasons.
ln -sv ../usr/bin/cpp /lib

# Many packages use the name cc to call the C compiler.
# To satisfy those packages, create a symlink:
ln -sv gcc /usr/bin/cc

# Add a compatibility symlink to enable building programs with
# Link Time Optimization (LTO):
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/7.3.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

# Now that our final toolchain is in place, it is important to again
# ensure that compiling and linking will work as expected. We do this
# by performing the same sanity checks as we did earlier in the chapter:
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

# Now make sure that we're setup to use the correct start files
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

# Verify that the compiler is searching for the correct header files:
grep -B4 '^ /usr/include' dummy.log

# Next, verify that the new linker is being used with the correct search paths:
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

# Next make sure that we're using the correct libc:
grep "/lib.*/libc.so.6 " dummy.log

# Lastly, make sure GCC is using the correct dynamic linker:
grep found dummy.log

# Once everything is working correctly, clean up the test files:
rm -v dummy.c a.out dummy.log

# Finally, move a misplaced file:
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

# Cleanup
popd \
  && rm -rf /tmp/gcc
