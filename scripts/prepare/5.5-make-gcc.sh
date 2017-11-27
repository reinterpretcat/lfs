#!/bin/bash
set -e
echo "Building gcc.."
echo "Approximate build time: 8.9 SBU"
echo "Required disk space: 2.2 GB"

# 5.5. Pass 1 GCC package contains the GNU compiler collection,
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
  && ../configure                                   \
    --target=$LFS_TGT                              \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++                       \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/gcc
