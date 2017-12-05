#!/bin/bash
set -e
echo "Continue with chroot environment.."

# configure system
sh /tools/7.2-make-lfs-bootscripts.sh
sh /tools/7.4-manage-devices.sh
sh /tools/7.5-configure-network.sh
sh /tools/7.6-configure-systemv.sh
sh /tools/7.x-configure-bash.sh
