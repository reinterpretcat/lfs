#!/bin/bash
set -e
echo "Building e2fsprogs.."
echo "Approximate build time: 3.3 SBU"
echo "Required disk space: 58 MB"

# 6.49. E2fsprogs package contains the utilities for handling the ext2
# file system. It also supports the ext3 and ext4 journaling file systems
tar -xf /sources/e2fsprogs-*.tar.gz -C /tmp/ \
  && mv /tmp/e2fsprogs-* /tmp/e2fsprogs \
  && pushd /tmp/e2fsprogs

mkdir -v build
cd build
LIBS=-L/tools/lib                     \
CFLAGS=-I/tools/include               \
PKG_CONFIG_PATH=/tools/lib/pkgconfig  \
../configure --prefix=/usr            \
    --bindir=/bin                     \
    --with-root-prefix=""             \
    --enable-elf-shlibs               \
    --disable-libblkid                \
    --disable-libuuid                 \
    --disable-uuidd                   \
    --disable-fsck
make
ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib
if [ $LFS_TEST -eq 1 ]; then  make LD_LIBRARY_PATH=/tools/lib check; fi
make install
make install-libs
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
# create and install some additional documentation
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
# cleanup
popd \
  && rm -rf /tmp/e2fsprogs
