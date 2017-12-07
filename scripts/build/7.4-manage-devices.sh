#!/bin/bash
set -e
echo "Managing devices.."

# patch script with docker vendor MAC prefix
sed -i "/declare -A VENDORS$/aVENDORS['02:42:ac:']=\"docker\"" /lib/udev/init-net-rules.sh

# generate udev rules for networking
bash /lib/udev/init-net-rules.sh

# inspect generated
cat /etc/udev/rules.d/70-persistent-net.rules
