#!/bin/bash
set -e
echo "Start.."

# prepare to build
/tools/run-prepare.sh

# execute rest as root
exec sudo -E -u root /bin/sh - << EOF
#  change ownership
chown -R root:root $LFS/tools

/tools/run-build.sh
/tools/run-image.sh
EOF
