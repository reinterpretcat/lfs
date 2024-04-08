#!/bin/bash
set -e
echo "Creating ramdisk.."

# Get the first available loopback device
LOOP=$(losetup -f)
echo "Loop device: $LOOP"

LOOP_DIR=$(pwd)/$LOOP
RAMDISK=$(pwd)/ramdisk

echo "Loop directory: $LOOP_DIR"

# Create yet another loop device if not exist
[ -e $LOOP ] || mknod $LOOP b 7 0

# create ramdisk file of IMAGE_SIZE
dd if=/dev/zero of=$RAMDISK bs=1k count=$IMAGE_SIZE

# plug off any virtual fs from loop device
losetup -d $LOOP || true

sync
# associate it with ${LOOP}
echo losetup $LOOP $RAMDISK
losetup $LOOP $RAMDISK
sync

# make an ext2 filesystem
echo mkfs.ext4 -q -m 0 $LOOP $IMAGE_SIZE
mkfs.ext4 -q -m 0 $LOOP $IMAGE_SIZE
sync

# ensure loop2 directory
[ -d $LOOP_DIR ] || mkdir -pv $LOOP_DIR

# mount it
mount $LOOP $LOOP_DIR
rm -rf $LOOP_DIR/lost+found

# copy LFS system without build artifacts
pushd $INITRD_TREE
cp -dpR $(ls -A | grep -Ev "sources|tools") $LOOP_DIR
popd

# show statistics
df $LOOP_DIR

echo "Compressing system ramdisk image.."
bzip2 -c $RAMDISK > $IMAGE

# Copy compressed image to /tmp dir (need for dockerhub)
cp -v $IMAGE .

# Cleanup
umount $LOOP_DIR
losetup -d $LOOP
rm -rf $LOOP_DIR
rm -f $RAMDISK
