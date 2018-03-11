#!/bin/bash
set -e
echo "Building Shadow.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 43 MB"

# 6.28. The Shadow package contains programs for handling passwords
# in a secure way.
tar -xf /sources/shadow-*.tar.xz -C /tmp/ \
  && mv /tmp/shadow-* /tmp/shadow \
  && pushd /tmp/shadow

# Disable the installation of the groups program and its man pages,
# as Coreutils provides a better version. Also Prevent the installation
# of manual pages that were already installed by the man pages package:
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

# Instead of using the default crypt method, use the more secure SHA-512
# method of password encryption, which also allows passwords longer
# than 8 characters. It is also necessary to change the obsolete
# /var/spool/mail location for user mailboxes that Shadow uses by
# default to the /var/mail location used currently:
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs

# Make a minor change to make the first group number generated
# by useradd 1000:
sed -i 's/1000/999/' etc/useradd

# Prepare Shadow for compilation:
./configure --sysconfdir=/etc --with-group-name-max-length=32

# Compile the package:
make

# Install the package:
make install

# Move a misplaced program to its proper location:
mv -v /usr/bin/passwd /bin

# Cleanup
popd \
  && rm -rf /tmp/shadow
