#!/bin/bash
set -e
echo "Managing devices.."

# generate udev rules for networking
bash /lib/udev/init-net-rules.sh
# inspect generated
cat /etc/udev/rules.d/70-persistent-net.rules
