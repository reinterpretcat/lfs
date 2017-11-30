#!/bin/bash
set -e
echo "Running build.."

sh /tools/6.2-prepare-vkfs.sh

# enter and continue in chroot environment
chroot "$LFS" /tools/bin/env -i                 \
  HOME=/root                                    \
  TERM="$TERM"                                  \
  PS1='\u:\w\$ '                                \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
  LFS_TEST=$LFS_TEST                            \
  /tools/bin/bash --login +h                    \
  -c "sh /tools/as-chroot.sh"
