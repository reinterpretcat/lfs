#!/bin/bash
set -e
echo "Continue with chroot environment.."
. /tools/.variables

# configure system
/tools/7.2-make-lfs-bootscripts.sh
/tools/7.4-manage-devices.sh
/tools/7.5-configure-network.sh
/tools/7.6-configure-systemv.sh
/tools/7.x-configure-bash.sh

# make system bootable
/tools/8.2-create-fstab.sh
/tools/8.3-make-linux-kernel.sh
/tools/8.4-setup-grub.sh

# end
/tools/9.1-the-end.sh

exit
