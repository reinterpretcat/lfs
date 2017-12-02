#!/bin/bash
set -e
echo "Running build.."

sh /tools/6.2-prepare-vkfs.sh

# enter and continue in chroot environment with tools
chroot "$LFS" /tools/bin/env -i                 \
  HOME=/root                                    \
  TERM="$TERM"                                  \
  PS1='\u:\w\$ '                                \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
  LFS_TEST=$LFS_TEST                            \
  /tools/bin/bash --login +h                    \
  -c "sh /tools/as-chroot-with-tools.sh"

# enter and continue in chroot environment with usr
chroot "$LFS" /usr/bin/env -i            \
  HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin     \
  /bin/bash --login                      \
  -c "sh /tools/as-chroot-with-usr.sh"
