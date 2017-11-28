#!/bin/bash
echo "Preparing Virtual Kernel File Systems.."

# create directories onto which the file systems will be mounted
mkdir -pv $LFS/{dev,proc,sys,run}

# create Initial Device Nodes
mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3

# mount and populate /dev
mount -v --bind /dev $LFS/dev

# mount Virtual Kernel File Systems
mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi
