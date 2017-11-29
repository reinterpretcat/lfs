FROM debian:8

# image info
LABEL description="Automated LFS build"
LABEL version="8.1"
LABEL maintainer="ilya.builuk@gmail.com"

# GNU make --jobs parameter which specifies maximum number
# of jobs can be run in parallel
ARG JOB_COUNT=1
# sets flag whether test suites for some packages should be run
ARG LFS_TEST=1

# set variables
ENV LFS=/mnt/lfs

# set bash as default shell
WORKDIR /bin
RUN rm sh && ln -s bash sh

# install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    bison           \
    file            \
    gawk            \
    texinfo         \
    wget            \
 && apt-get -q -y autoremove \
 && rm -rf /var/lib/apt/lists/*

# create sources directory as writable and sticky
RUN mkdir -pv $LFS/sources \
 && chmod -v a+wt $LFS/sources
WORKDIR $LFS/sources

# create tools directory and symlink
RUN mkdir -pv $LFS/tools \
 && ln -sv $LFS/tools /

# copy prepare scripts and check environment
COPY [ "scripts/prepare/", "$LFS/tools/" ]
RUN chmod +x $LFS/tools/*.sh \
 && sync               \
 && $LFS/tools/version-check.sh \
 && $LFS/tools/library-check.sh

# create lfs user with 'lfs' password
RUN groupadd lfs \
 && useradd -s /bin/bash -g lfs -m -k /dev/null lfs \
 && echo "lfs:lfs" | chpasswd

# give lfs user ownership of directories
RUN chown -v lfs $LFS/tools \
 && chown -v lfs $LFS/sources

 # login as lfs user and set up environment
USER lfs
COPY [ "scripts/prepare/.bash_profile", "scripts/prepare/.bashrc", "/home/lfs/" ]
RUN source ~/.bash_profile

# must be defined as ENV to be accessible by RUN commands
ENV LC_ALL=POSIX \
  LFS_TGT=x86_64-lfs-linux-gnu \
  PATH=/tools/bin:/bin:/usr/bin \
  MAKEFLAGS="-j $JOB_COUNT"

# download toolchain
RUN sh /tools/3.1-download-tools.sh

# build toolchain
RUN sh /tools/5.4-make-binutils.sh
RUN sh /tools/5.5-make-gcc.sh
RUN sh /tools/5.6-make-linux-api-headers.sh
RUN sh /tools/5.7-make-glibc.sh
RUN sh /tools/5.8-make-libstdc.sh
RUN sh /tools/5.9-make-binutils.sh
RUN sh /tools/5.10-make-gcc.sh
RUN sh /tools/5.11-make-tcl.sh
RUN sh /tools/5.12-make-expect.sh
RUN sh /tools/5.13-make-dejagnu.sh
RUN sh /tools/5.14-make-check.sh
RUN sh /tools/5.15-make-ncurses.sh
RUN sh /tools/5.16-make-bash.sh
RUN sh /tools/5.17-make-bison.sh
RUN sh /tools/5.18-make-bzip2.sh
RUN sh /tools/5.19-make-coreutils.sh
RUN sh /tools/5.20-make-diffutils.sh
RUN sh /tools/5.21-make-file.sh
RUN sh /tools/5.22-make-findutils.sh
RUN sh /tools/5.23-make-gawk.sh
RUN sh /tools/5.24-make-gettext.sh
RUN sh /tools/5.25-make-grep.sh
RUN sh /tools/5.26-make-gzip.sh
RUN sh /tools/5.27-make-m4.sh
RUN sh /tools/5.28-make-make.sh
RUN sh /tools/5.29-make-patch.sh
RUN sh /tools/5.30-make-perl.sh
RUN sh /tools/5.31-make-sed.sh
RUN sh /tools/5.32-make-tar.sh
RUN sh /tools/5.33-make-texinfo.sh
RUN sh /tools/5.34-make-util-linux.sh
RUN sh /tools/5.35-make-xz.sh
RUN sh /tools/5.36-strip.sh

# change ownership
USER root
# NOTE root:root returns an error
RUN chown -R `stat -c "%u:%g" ~` $LFS/tools

# copy build scripts
COPY [ "scripts/build/", "$LFS/tools/" ]
RUN chmod +x $LFS/tools/*.sh

# run actual building lfs when container starts
ENTRYPOINT [ "../tools/run-build.sh" ]
