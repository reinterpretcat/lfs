FROM debian:8

# image info
LABEL description="Automated LFS build"
LABEL version="8.1"
LABEL maintainer="ilya.builuk@gmail.com"

# LFS mount point
ENV LFS=/mnt/lfs

# set bash as default shell
WORKDIR /bin
RUN rm sh && ln -s bash sh

# install required packages
RUN apt-get update && apt-get install -y \
    build-essential                      \
    bison                                \
    file                                 \
    gawk                                 \
    texinfo                              \
    wget                                 \
 && apt-get -q -y autoremove             \
 && rm -rf /var/lib/apt/lists/*

# create sources directory as writable and sticky
RUN mkdir -pv     $LFS/sources \
 && chmod -v a+wt $LFS/sources
WORKDIR $LFS/sources

# create tools directory and symlink
RUN mkdir -pv $LFS/tools \
 && ln    -sv $LFS/tools /

# copy scripts
COPY [ "scripts/prepare/", "scripts/build/", "scripts/image/", "$LFS/tools/" ]
# copy configuration
COPY [ "config/.variables",  "config/kernel.config", "$LFS/tools/" ]

# check environment
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
COPY [ "config/.bash_profile", "config/.bashrc", "/home/lfs/" ]
RUN source ~/.bash_profile

# let's the party begin
ENTRYPOINT [ "/tools/run-all.sh" ]
