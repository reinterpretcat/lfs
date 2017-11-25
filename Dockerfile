FROM debian:8
CMD ["/bin/bash"]

# GNU make --jobs parameter which specifies
# maximum number of jobs can be run in parallel
ARG JOB_COUNT=1

# set variables
ENV LFS=/mnt/lfs

# set bash as default shell
WORKDIR /bin
RUN rm sh && ln -s bash sh

# install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    bison \
    file \
    gawk \
    texinfo \
    wget \
 && apt-get -q -y autoremove \
 && rm -rf /var/lib/apt/lists/*

 # create sources directory as writable and sticky
 RUN mkdir -pv $LFS/sources \
  && chmod -v a+wt $LFS/sources
 WORKDIR $LFS/sources

# create tools directory and symlink
RUN mkdir -pv $LFS/tools \
 && ln -sv $LFS/tools /

# check environment
COPY [ "scripts/version-check.sh", "scripts/library-check.sh", "$LFS/sources/" ]
RUN chmod -v 755 *.sh && sync \
 && ./version-check.sh && ./library-check.sh

 # create lfs user with 'lfs' password
RUN groupadd lfs \
 && useradd -s /bin/bash -g lfs -m -k /dev/null lfs \
 && echo "lfs:lfs" | chpasswd

# give lfs user ownership of directories
RUN chown -v lfs $LFS/tools \
 && chown -v lfs $LFS/sources

 # login as lfs user and set up environment
USER lfs
COPY [ "scripts/.bash_profile", "scripts/.bashrc", "/home/lfs/" ]
RUN source ~/.bash_profile

# must be defined as ENV to be accessible by RUN commands
ENV LC_ALL=POSIX \
  LFS_TGT=x86_64-lfs-linux-gnu \
  PATH=/tools/bin:/bin:/usr/bin \
  MAKEFLAGS="-j $JOB_COUNT"

# compile binutils package which contains a linker, an assembler,
# and other tools for handling object files
COPY [ "toolchain/binutils-*.tar.bz2", "$LFS/sources/" ]
RUN tar -xf binutils-*.tar.bz2 -C /tmp/ \
 && mv /tmp/binutils-* /tmp/binutils \
 && pushd /tmp/binutils \
 && mkdir -v build \
 && cd build \
 && ../configure               \
    --prefix=/tools            \
    --with-sysroot=$LFS        \
    --with-lib-path=/tools/lib \
    --target=$LFS_TGT          \
    --disable-nls              \
    --disable-werror           \
 && make \
 && mkdir -pv /tools/lib \
 && ln -sv lib /tools/lib64 \
 && make install \
 && popd \
 && rm -rf /tmp/binutils

# Pass 1: compile GCC package which contains the GNU compiler collection,
# including the C and C++ compilers
COPY [ "toolchain/gcc-*.tar.xz", "toolchain/mpfr-*.tar.xz", "toolchain/gmp-*.tar.xz", "toolchain/mpc-*.tar.gz", "$LFS/sources/" ]
RUN tar -xf gcc-*.tar.xz -C /tmp/ \
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

# compile Linux API headers which expose the kernel's API
# for use by Glibc
COPY [ "toolchain/linux-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf linux-*.tar.xz -C /tmp/ \
 && mv /tmp/linux-* /tmp/linux \
 && pushd /tmp/linux \
 && make mrproper \
 && make INSTALL_HDR_PATH=dest headers_install \
 && cp -rv dest/include/* /tools/include \
 && popd \
 && rm -rf /tmp/linux

# compile Glibc which contains the main C library
COPY [ "toolchain/glibc-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf glibc-*.tar.xz -C /tmp/ \
 && mv /tmp/glibc-* /tmp/glibc \
 && pushd /tmp/glibc \
 && mkdir -v build \
 && cd build \
 && ../configure                       \
    --prefix=/tools                    \
    --host=$LFS_TGT                    \
    --build=$(../scripts/config.guess) \
    --enable-kernel=3.2                \
    --with-headers=/tools/include      \
    libc_cv_forced_unwind=yes          \
    libc_cv_c_cleanup=yes              \
&& make \
&& make install \
&& popd \
&& rm -rf /tmp/glibc

# perform a sanity check that basic functions (compiling and linking)
# are working as expected
RUN echo 'int main(){}' > dummy.c \
 && $LFS_TGT-gcc dummy.c \
 && readelf -l a.out | grep ': /tools' \
 && rm -v dummy.c a.out

# compile libstdc++ which is standard C++ library,
# needed for the correct operation of the g++ compiler
COPY [ "toolchain/gcc-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf gcc-*.tar.xz -C /tmp/ \
 && mv /tmp/gcc-* /tmp/gcc \
 && pushd /tmp/gcc \
 && mkdir -v build \
 && cd build \
 && ../libstdc++-v3/configure        \
     --host=$LFS_TGT                 \
     --prefix=/tools                 \
     --disable-multilib              \
     --disable-nls                   \
     --disable-libstdcxx-threads     \
     --disable-libstdcxx-pch         \
     --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/7.2.0 \
 && make \
 && make install \
 && popd \
 && rm -rf /tmp/gcc

# Pass 2: compile binutils package
RUN tar -xf binutils-*.tar.bz2 -C /tmp/ \
 && mv /tmp/binutils-* /tmp/binutils \
 && pushd /tmp/binutils \
 && mkdir -v build \
 && cd build \
 && CC=$LFS_TGT-gcc              \
    AR=$LFS_TGT-ar               \
    RANLIB=$LFS_TGT-ranlib       \
    ../configure                 \
      --prefix=/tools            \
      --disable-nls              \
      --disable-werror           \
      --with-lib-path=/tools/lib \
      --with-sysroot             \
 && make \
 && make install \
 && make -C ld clean \
 && make -C ld LIB_PATH=/usr/lib:/lib \
 && cp -v ld/ld-new /tools/bin \
 && popd \
 && rm -rf /tmp/binutils

 # Pass 2: compile GCC package
RUN tar -xf gcc-*.tar.xz -C /tmp/ \
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
 && ../configure                                     \
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
RUN echo 'int main(){}' > dummy.c \
 && cc dummy.c \
 && readelf -l a.out | grep ': /tools' \
 && rm -v dummy.c a.out
