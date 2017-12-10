#!/bin/bash
set -e
echo "Setup general network configuration.."

# 7.5.1 create a sample file for the wlp3s0 device with a static IP address
# TODO make params configurable
cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=10.0.2.15
GATEWAY=10.0.2.2
PREFIX=24
BROADCAST=10.0.2.255
EOF

# 7.5.2 DNS configuration
cat > /etc/resolv.conf << "EOF"
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# 7.5.3 configure system hostname
echo "lfs" > /etc/hostname

# 7.5.4 customize /etc/hosts file
# TODO values need to be changed for specific uses or requirements
cat > /etc/hosts << "EOF"
127.0.0.1 localhost
# 127.0.1.1 <FQDN> <HOSTNAME>
# <192.168.1.1> <FQDN> <HOSTNAME> [alias1] [alias2 ...]
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
