FROM debian:8
CMD ["/bin/bash"]

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

# compile binutils
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

# compile gcc
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
 && rm -rf /tmp/gcc-*
