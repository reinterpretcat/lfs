#!/bin/bash
set -e
echo "Continue with chroot environment.."
. /tools/.variables

# configure system
sh /tools/7.2-make-lfs-bootscripts.sh
sh /tools/7.4-manage-devices.sh
sh /tools/7.5-configure-network.sh
sh /tools/7.6-configure-systemv.sh
sh /tools/7.x-configure-bash.sh

# make system bootable
sh /tools/8.2-create-fstab.sh
sh /tools/8.3-make-linux-kernel.sh
sh /tools/8.4-setup-grub.sh

# end
sh /tools/9.1-the-end.sh

exit
