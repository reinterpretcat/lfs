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
COPY [ "toolchain/binutils-*.tar.bz2", "$LFS/sources/binutils.tar.bz2" ]
RUN tar -xf binutils.tar.bz2 -C /tmp/ \
 && mv /tmp/binutils* /tmp/binutils \
 && pushd /tmp/binutils \
 && mkdir -v build \
 && cd build \
 && ../configure     \
    --prefix=/tools            \
    --with-sysroot=$LFS        \
    --with-lib-path=/tools/lib \
    --target=$LFS_TGT          \
    --disable-nls              \
    --disable-werror \
 && make \
 && mkdir -pv /tools/lib \
 && ln -sv lib /tools/lib64 \
 && make install \
 && popd \
 && rm -rf /tmp/binutils
