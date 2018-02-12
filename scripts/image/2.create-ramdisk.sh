#!/bin/bash
set -e
echo "Creating ramdisk.."

LOOP_DIR=$(pwd)/loop2

# create ramdisk file of IMAGE_SIZE
dd if=/dev/zero of=ramdisk bs=1k count=$IMAGE_SIZE

# associate it with ${LOOP}
losetup ${LOOP} ramdisk

# make an ext2 filesystem
mke2fs -q -i 16384 -m 0 ${LOOP} $IMAGE_SIZE

# ensure loop2 directory
[ -d $LOOP_DIR ] || mkdir -pv $LOOP_DIR

# mount it
mount ${LOOP} $LOOP_DIR
rm -rf $LOOP_DIR/lost+found

# copy LFS system without build artifacts
pushd $INITRD_TREE
cp -dpR $(ls -A | grep -Ev "sources|tools") $LOOP_DIR
popd

# show statistics
df loop2

echo "Compressing system ramdisk image.."
bzip2 -c ramdisk > $IMAGE

# cleanup
umount loop2
losetup -d ${LOOP}
rm  -rf loop2
rm -f ramdisk
