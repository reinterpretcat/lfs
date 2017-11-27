#!/bin/bash
set -e
echo "Building gcc.."
echo "Approximate build time: 11 SBU"
echo "Required disk space: 2.6 GB"

# 5.10. Pass 2 GCC package contains the GNU compiler collection,
# which includes the C and C++ compilers
tar -xf gcc-*.tar.xz -C /tmp/ \
  && mv /tmp/gcc-* /tmp/gcc \
  && pushd /tmp/gcc \
  && tar -xf $LFS/sources/mpfr-*.tar.xz \
  && mv -v mpfr-* mpfr \
  && tar -xf $LFS/sources/gmp-*.tar.xz \
  && mv -v gmp-* gmp \
  && tar -xf $LFS/sources/mpc-*.tar.gz \
  && mv -v mpc-* mpc \
  && cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
      `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h \
  && for file in gcc/config/{linux,i386/linux{,64}}.h; do \
     cp -uv $file{,.orig}; \
     sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' -e 's@/usr@/tools@g' $file.orig > $file; \
     echo -e "#undef STANDARD_STARTFILE_PREFIX_1 \n#undef STANDARD_STARTFILE_PREFIX_2 \n#define STANDARD_STARTFILE_PREFIX_1 \"/tools/lib/\" \n#define STANDARD_STARTFILE_PREFIX_2 \"\"" >> $file; \
     touch $file.orig; \
    done \
  && case $(uname -m) in \
     x86_64) \
       sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 \
      ;; \
    esac \
  && mkdir -v build \
  && cd build \
  && CC=$LFS_TGT-gcc        \
    CXX=$LFS_TGT-g++       \
    AR=$LFS_TGT-ar         \
    RANLIB=$LFS_TGT-ranlib \
    ../configure                                     \
      --prefix=/tools                                \
      --with-local-prefix=/tools                     \
      --with-native-system-header-dir=/tools/include \
      --enable-languages=c,c++                       \
      --disable-libstdcxx-pch                        \
      --disable-multilib                             \
      --disable-bootstrap                            \
      --disable-libgomp                              \
  && make \
  && make install \
  && ln -sv gcc /tools/bin/cc \
  && popd \
  && rm -rf /tmp/gcc

# perform a sanity check
echo 'int main(){}' > dummy.c \
  && cc dummy.c \
  && readelf -l a.out | grep ': /tools' \
  && rm -v dummy.c a.out
