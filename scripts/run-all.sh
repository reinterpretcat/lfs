#!/bin/bash
set -e
echo "Running build.."

. /tools/.variables

sh /tools/run-prepare.sh

# return to root
exit
#  change ownership
chown -R root:root $LFS/tools

sh /tools/run-build.sh

#sh /tools/run-boot.sh
