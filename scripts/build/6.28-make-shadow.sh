#!/bin/bash
set -e
echo "Building shadow.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 42 MB"

# 6.28. Shadow package contains programs for handling passwords in a secure way
tar -xf /sources/shadow-*.tar.xz -C /tmp/ \
  && mv /tmp/shadow-* /tmp/shadow \
  && pushd /tmp/shadow
# disable the installation of the groups program and its man pages
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
# instead of using the default crypt method, use the more secure
# SHA-512 method of password encryption
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
# make a minor change to make the default useradd consistent
# with the LFS groups file
sed -i 's/1000/999/' etc/useradd
# prepare
./configure --sysconfdir=/etc --with-group-name-max-length=32
# compile and install
make
make install
mv -v /usr/bin/passwd /bin
# cleanup
popd \
  && rm -rf /tmp/shadow
