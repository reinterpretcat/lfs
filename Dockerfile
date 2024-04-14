FROM debian:10-slim

# image info
LABEL description="Automated LFS build"

LABEL version="8.21"

LABEL maintainer="ilya.builuk@gmail.com"


# install required packages
RUN apt-get update && apt-get install -y \
    build-essential                      \
    bison                                \
    file                                 \
    gawk                                 \
    texinfo                              \
    wget                                 \
    sudo                                 \
    genisoimage                          \
    libelf-dev                           \
    bc                                   \
    libssl-dev                           \
 && apt-get -q -y autoremove             \
 && rm -rf /var/lib/apt/lists/*


# LFS mount point
ENV LFS=/mnt/lfs

# Other LFS parameters
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV MAKEFLAGS="-j 30"

# Defines how toolchain is fetched
# 0 use LFS wget file
# 1 use binaries from toolchain folder
# 2 use github release artifacts
ENV FETCH_TOOLCHAIN_MODE=1

# set 1 to run tests; running tests takes much more time
ENV LFS_TEST=0

# set 1 to install documentation; slightly increases final size
ENV LFS_DOCS=0

# degree of parallelism for compilation
ENV JOB_COUNT=30

# inital ram disk size in KB
# must be in sync with CONFIG_BLK_DEV_RAM_SIZE
ENV IMAGE_SIZE=900000

# location of initrd tree
ENV INITRD_TREE=/mnt/lfs

# output image
ENV IMAGE=isolinux/ramdisk.img

# set bash as default shell
WORKDIR /bin
RUN rm sh && ln -s bash sh

# create sources directory as writable and sticky
RUN mkdir -pv     $LFS/sources \
 && chmod -v a+wt $LFS/sources
WORKDIR $LFS/sources

# create tools directory and symlink
RUN mkdir -pv $LFS/tools   \
 && ln    -sv $LFS/tools /

# copy local binaries if present
COPY ["toolchain/", "$LFS/sources/"]

# copy scripts
COPY [ "scripts/run-all.sh",       \
       "scripts/library-check.sh", \
       "scripts/version-check.sh", \
       "scripts/prepare/",         \
       "scripts/build/",           \
       "scripts/image/",           \
       "$LFS/tools/" ]
# copy configuration
COPY [ "config/kernel.config", "$LFS/tools/" ]

# check environment
RUN chmod +x $LFS/tools/*.sh    \
 && sync                        \
 && $LFS/tools/version-check.sh \
 && $LFS/tools/library-check.sh

# create lfs user with 'lfs' password
RUN groupadd lfs                                    \
 && useradd -s /bin/bash -g lfs -m -k /dev/null lfs \
 && echo "lfs:lfs" | chpasswd
RUN adduser lfs sudo

# give lfs user ownership of directories
RUN chown -v lfs $LFS/tools  \
 && chown -v lfs $LFS/sources

# avoid sudo password
RUN echo "lfs ALL = NOPASSWD : ALL" >> /etc/sudoers
RUN echo 'Defaults env_keep += "LFS LC_ALL LFS_TGT PATH MAKEFLAGS FETCH_TOOLCHAIN_MODE LFS_TEST LFS_DOCS JOB_COUNT LOOP IMAGE_SIZE INITRD_TREE IMAGE"' >> /etc/sudoers

# login as lfs user
USER lfs
COPY [ "config/.bash_profile", "config/.bashrc", "/home/lfs/" ]
RUN source ~/.bash_profile

# download toolchain
RUN /tools/3.1-download-tools.sh

# build toolchain. Formally this code was in run-prepare.sh
# We do it here to take advantage of layering
RUN /tools/5.4-make-binutils.sh
RUN /tools/5.5-make-gcc.sh
RUN /tools/5.6-make-linux-api-headers.sh
RUN /tools/5.7-make-glibc.sh
RUN /tools/5.8-make-libstdc.sh
RUN /tools/5.9-make-binutils.sh
RUN /tools/5.10-make-gcc.sh
RUN /tools/5.11-make-tcl.sh
RUN /tools/5.12-make-expect.sh
RUN /tools/5.13-make-dejagnu.sh
RUN /tools/5.14-make-m4.sh
RUN /tools/5.15-make-ncurses.sh
RUN /tools/5.16-make-bash.sh
RUN /tools/5.17-make-bison.sh
RUN /tools/5.18-make-bzip2.sh
RUN /tools/5.19-make-coreutils.sh
RUN /tools/5.20-make-diffutils.sh
RUN /tools/5.21-make-file.sh
RUN /tools/5.22-make-findutils.sh
RUN /tools/5.23-make-gawk.sh
RUN /tools/5.24-make-gettext.sh
RUN /tools/5.25-make-grep.sh
RUN /tools/5.26-make-gzip.sh
RUN /tools/5.27-make-make.sh
RUN /tools/5.28-make-patch.sh
RUN /tools/5.29-make-perl.sh
RUN /tools/5.30-make-sed.sh
RUN /tools/5.31-make-tar.sh
RUN /tools/5.32-make-texinfo.sh
RUN /tools/5.33-make-util-linux.sh
RUN /tools/5.34-make-xz.sh
RUN /tools/5.35-strip.sh
# Everything so far has been done in un-privileged mode. Now we need to switch to privileged mode
# because the rest of the LFS build requires us to use the mount command.

# execute rest as root
USER root
RUN chown -R root:root $LFS/tools && sync
# formally this code was in run-build.sh

# let's the party begin
ENTRYPOINT [ "/tools/run-build.sh" ]
