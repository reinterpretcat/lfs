#!/bin/bash
set -e
echo "Creating ramdisk.."

# create ramdisk file of IMAGE_SIZE
dd if=/dev/zero of=ramdisk bs=1k count=$IMAGE_SIZE
# associate it with ${LOOP}
losetup ${LOOP} ramdisk

# make an ext2 filesystem
mke2fs -q -i 16384 -m 0 ${LOOP} IMAGE_SIZE

# make sure we have loop2 directory
[ -d  loop2 ] || mkdir  loop2

# mount it
mount ${LOOP} loop2
rm -rf loop2/lost+found

# copy the contents of our initrdtree to this filesystem
cp -dpR INITRD_TREE/* loop2/

df loop2

# and unmount and divorce ${LOOP}
umount loop2
losetup -d ${LOOP}

# delete any existing one
rm -f $IMAGE
echo -n "Compressing system ramdisk image.... "
bzip2 -c ramdisk > $IMAGE
# cleanup
rm -f ramdisk
