FROM debian:8
CMD ["/bin/bash"]

# GNU make --jobs parameter which specifies
# maximum number of jobs can be run in parallel
ARG JOB_COUNT=1
# sets flag whether test suites for some packages
# should be run
ARG LFS_TEST=1

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

 # compile TCL-core package which contains the Tool Command Language
COPY [ "toolchain/tcl-core*-src.tar.gz", "$LFS/sources/" ]
RUN tar -xf tcl-core*-src.tar.gz -C /tmp/ \
 && mv /tmp/tcl* /tmp/tcl-core \
 && pushd /tmp/tcl-core \
 && cd unix \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then TZ=UTC make test; fi \
 && make install \
 && chmod -v u+w /tools/lib/libtcl8.6.so \
 && make install-private-headers \
 && ln -sv tclsh8.6 /tools/bin/tclsh \
 && popd \
 && rm -rf /tmp/tcl-core

# compile expect package package which contains a program
# for carrying out scripted dialogues with other interactive programs
COPY [ "toolchain/expect*.tar.gz", "$LFS/sources/" ]
RUN tar -xf expect*.tar.gz -C /tmp/ \
 && mv /tmp/expect* /tmp/expect \
 && pushd /tmp/expect \
 && cp -v configure{,.orig} \
 && sed 's:/usr/local/bin:/bin:' configure.orig > configure \
 && ./configure --prefix=/tools        \
      --with-tcl=/tools/lib            \
      --with-tclinclude=/tools/include \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make test; fi \
 && make SCRIPTS="" install \
 && popd \
 && rm -rf /tmp/expect

# compile DejaGNU which contains a framework for testing other programs
COPY [ "toolchain/dejagnu-*.tar.gz", "$LFS/sources/" ]
RUN  tar -xf dejagnu-*.tar.gz -C /tmp/ \
 && mv /tmp/dejagnu-* /tmp/dejagnu \
 && pushd /tmp/dejagnu \
 && ./configure --prefix=/tools \
 && make install \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && popd \
 && rm -rf /tmp/dejagnu

 # compile check package which is a unit testing framework for C.
COPY [ "toolchain/check-*.tar.gz", "$LFS/sources/" ]
RUN tar -xf check-*.tar.gz -C /tmp/ \
 && mv /tmp/check-* /tmp/check \
 && pushd /tmp/check \
 && PKG_CONFIG= ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/check

# compile ncurses packages which contains libraries
# for terminal-independent handling of character screens
COPY [ "toolchain/ncurses-*.tar.gz", "$LFS/sources/" ]
RUN tar -xf ncurses-*.tar.gz -C /tmp/ \
 && mv /tmp/ncurses-* /tmp/ncurses \
 && pushd /tmp/ncurses \
 && sed -i s/mawk// configure \
 && ./configure          \
      --prefix=/tools    \
      --with-shared      \
      --without-debug    \
      --without-ada      \
      --enable-widec     \
      --enable-overwrite \
 && make \
 && make install \
 && popd \
 && rm -rf /tmp/ncurses

 # compile bash package which contains the Bourne-Again SHell
COPY [ "toolchain/bash-*.tar.gz", "$LFS/sources/" ]
RUN tar -xf bash-*.tar.gz -C /tmp/ \
 && mv /tmp/bash-* /tmp/bash \
 && pushd /tmp/bash \
 && ./configure --prefix=/tools --without-bash-malloc \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make tests; fi \
 && make install \
 && ln -sv bash /tools/bin/sh \
 && popd \
 && rm -rf /tmp/bash

 # compile Bison package which contains a parser generator
COPY [ "toolchain/bison-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf bison-*.tar.xz -C /tmp/ \
 && mv /tmp/bison-* /tmp/bison \
 && pushd /tmp/bison \
 && ./configure --prefix=/tools \
 && make \
 && make install \
 && popd \
 && rm -rf /tmp/bison

# compile bzip2 package which contains programs for
# compressing and decompressing files.
COPY [ "toolchain/bzip2-*.tar.gz", "$LFS/sources/" ]
RUN tar -xf bzip2-*.tar.gz -C /tmp/ \
 && mv /tmp/bzip2-* /tmp/bzip2 \
 && pushd /tmp/bzip2 \
 && make \
 && make PREFIX=/tools install \
 && popd \
 && rm -rf /tmp/bzip2

# compile coreutils package which contains utilities
# for showing and setting the basic system characteristics
# NOTE: has failed tests
# NOTE: has workaround for deletion directiories with long name
COPY [ "toolchain/coreutils-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf coreutils-*.tar.xz -C /tmp/ \
 && mv /tmp/coreutils-* /tmp/coreutils \
 && pushd /tmp/coreutils \
 && ./configure --prefix=/tools --enable-install-program=hostname \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make RUN_EXPENSIVE_TESTS=yes check || true; fi \
 && make install \
 && popd \
 && rm -rf /tmp/coreutils || true

# compile diffutils package which contains programs that
# show the differences between files or directories
COPY [ "toolchain/diffutils-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf diffutils-*.tar.xz -C /tmp/ \
 && mv /tmp/diffutils-* /tmp/diffutils \
 && pushd /tmp/diffutils \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/diffutils

# compile file package which contains a utility for determining
# the type of a given file or files
COPY [ "toolchain/file-*.tar.gz", "$LFS/sources/" ]
RUN tar -xf file-*.tar.gz -C /tmp/ \
 && mv /tmp/file-* /tmp/file \
 && pushd /tmp/file \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/file

# compile findutils package contains programs to find files
COPY [ "toolchain/findutils-*.tar.gz", "$LFS/sources/" ]
RUN tar -xf findutils-*.tar.gz -C /tmp/ \
 && mv /tmp/findutils-* /tmp/findutils \
 && pushd /tmp/findutils \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi || true \
 && make install \
 && popd \
 && rm -rf /tmp/findutils || true

# compile gawk package which contains programs for manipulating text files
COPY [ "toolchain/gawk-*.tar.xz", "$LFS/sources/" ]
RUN  tar -xf gawk-*.tar.xz -C /tmp/ \
 && mv /tmp/gawk-* /tmp/gawk \
 && pushd /tmp/gawk \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check || true; fi \
 && make install \
 && popd \
 && rm -rf /tmp/gawk

# compile gettext package which contains utilities for
# internationalization and localization
COPY [ "toolchain/gettext-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf gettext-*.tar.xz -C /tmp/ \
 && mv /tmp/gettext-* /tmp/gettext \
 && pushd /tmp/gettext \
 && cd gettext-tools \
 && EMACS="no" ./configure --prefix=/tools --disable-shared \
 && make -C gnulib-lib \
 && make -C intl pluralx.c \
 && make -C src msgfmt \
 && make -C src msgmerge \
 && make -C src xgettext \
 && cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin \
 && popd \
 && rm -rf /tmp/gettext

# compile grep which package contains programs for
# searching through files
COPY [ "toolchain/grep-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf grep-*.tar.xz -C /tmp/ \
 && mv /tmp/grep-* /tmp/grep \
 && pushd /tmp/grep \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/grep

# compile gzip package which contains programs for
# compressing and decompressing files
COPY [ "toolchain/gzip-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf gzip-*.tar.xz -C /tmp/ \
 && mv /tmp/gzip-* /tmp/gzip \
 && pushd /tmp/gzip \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check || true; fi \
 && make install \
 && popd \
 && rm -rf /tmp/gzip

# compile m4 package which contains a macro processor
COPY [ "toolchain/m4-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf m4-*.tar.xz -C /tmp/ \
 && mv /tmp/m4-* /tmp/m4 \
 && pushd /tmp/m4 \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/m4

# compile make package which contains a program for compiling packages
COPY [ "toolchain/make-*.tar.bz2", "$LFS/sources/" ]
RUN tar -xf make-*.tar.bz2 -C /tmp/ \
 && mv /tmp/make-* /tmp/make \
 && pushd /tmp/make \
 && ./configure --prefix=/tools --without-guile \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/make

# compile patch package which contains a program for modifying or
# creating files by applying a “patch” file typically created by
# the diff program
COPY [ "toolchain/patch-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf patch-*.tar.xz -C /tmp/ \
 && mv /tmp/patch-* /tmp/patch \
 && pushd /tmp/patch \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/patch

# compile perl package which contains the Practical Extraction
# and Report Language
COPY [ "toolchain/perl-5*.tar.xz", "$LFS/sources/" ]
RUN tar -xf perl-5*.tar.xz -C /tmp/ \
 && mv /tmp/perl-* /tmp/perl \
 && pushd /tmp/perl \
 && sed -e '9751 a#ifndef PERL_IN_XSUB_RE' \
        -e '9808 a#endif' \
        -i regexec.c \
 && sh Configure -des -Dprefix=/tools -Dlibs=-lm \
 && make \
 && cp -v perl cpan/podlators/scripts/pod2man /tools/bin \
 && mkdir -pv /tools/lib/perl5/5.26.0 \
 && cp -Rv lib/* /tools/lib/perl5/5.26.0 \
 && popd \
 && rm -rf /tmp/perl

# compile sed package which contains a stream editor
COPY [ "toolchain/sed-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf sed-*.tar.xz -C /tmp/ \
 && mv /tmp/sed-* /tmp/sed \
 && pushd /tmp/sed \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check || true; fi \
 && make install \
 && popd \
 && rm -rf /tmp/sed

# compile tar package which contains an archiving program
COPY [ "toolchain/tar-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf tar-*.tar.xz -C /tmp/ \
 && mv /tmp/tar-* /tmp/tar \
 && pushd /tmp/tar \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/tar || true

# compile texinfo package which contains programs for reading,
# writing, and converting info pages.
COPY [ "toolchain/texinfo-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf texinfo-*.tar.xz -C /tmp/ \
 && mv /tmp/texinfo-* /tmp/texinfo \
 && pushd /tmp/texinfo \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/texinfo

# compile util-linux package which contains miscellaneous utility programs
COPY [ "toolchain/util-linux-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf util-linux-*.tar.xz -C /tmp/ \
 && mv /tmp/util-linux-* /tmp/util-linux \
 && pushd /tmp/util-linux \
 && ./configure --prefix=/tools     \
     --without-python               \
     --disable-makeinstall-chown    \
     --without-systemdsystemunitdir \
     --without-ncurses              \
     PKG_CONFIG=""                  \
&& make \
&& make install \
&& popd \
&& rm -rf /tmp/util-linux

# compile xz package which contains programs for compressing and
# decompressing files
COPY [ "toolchain/xz-*.tar.xz", "$LFS/sources/" ]
RUN tar -xf xz-*.tar.xz -C /tmp/ \
 && mv /tmp/xz-* /tmp/xz \
 && pushd /tmp/xz \
 && ./configure --prefix=/tools \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/xz

# stripping unneeded files to reduce LFS size
RUN strip --strip-debug /tools/lib/* || true
RUN /usr/bin/strip --strip-unneeded /tools/{,s}bin/* || true
RUN rm -rf /tools/{,share}/{info,man,doc}

# change ownership
USER root
# NOTE root:root returns an error
RUN chown -R `stat -c "%u:%g" ~` $LFS/tools


### Building the LFS System ###

# prepare Virtual Kernel File Systems
RUN mkdir -pv $LFS/{dev,proc,sys,run}

# create Initial Device Nodes
RUN mknod -m 600 $LFS/dev/console c 5 1
RUN mknod -m 666 $LFS/dev/null c 1 3

# mount and populate /dev
RUN mount -v --bind /dev $LFS/dev

# mount Virtual Kernel File Systems
RUN mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
RUN mount -vt proc proc $LFS/proc
RUN mount -vt sysfs sysfs $LFS/sys
RUN mount -vt tmpfs tmpfs $LFS/run
RUN if [ -h $LFS/dev/shm ]; then mkdir -pv $LFS/$(readlink $LFS/dev/shm) fi
