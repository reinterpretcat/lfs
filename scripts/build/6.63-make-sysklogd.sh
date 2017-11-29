#!/bin/bash
set -e
echo "Building sysklogd.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 0.7 MB"

#
tar -xf /sources/sysklogd-*.tar.gz -C /tmp/ \
  && mv /tmp/sysklogd-* /tmp/sysklogd \
  && pushd /tmp/sysklogd
# fix bugs
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c
# compile
make
# install
make BINDIR=/sbin install
# 6.63.2. Configuring Sysklogd
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf
auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *
# End /etc/syslog.conf
EOF

# cleanup
popd \
  && rm -rf /tmp/sysklogd
