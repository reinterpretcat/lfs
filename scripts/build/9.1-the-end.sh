#!/bin/bash
set -e
echo "Finalize LFS configuration.."

# LFS version file
echo 8.1 > /etc/lfs-release

# LSB version file
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="8.1"
DISTRIB_CODENAME="reinterpretcat"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF
