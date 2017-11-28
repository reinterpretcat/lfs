#!/bin/bash
set -e
echo "Building perl.."
echo "Approximate build time: 8.6 SBU"
echo "Required disk space: 257 MB"

# 6.40. Perl package contains the Practical Extraction and Report Language
tar -xf perl-*.tar.xz -C /tmp/ \
  && mv /tmp/perl-* /tmp/perl \
  && pushd /tmp/perl
# create a basic /etc/hosts file to be referenced in one of Perl's configuration
# files as well as the optional test suite
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
# use libs installed in system
export BUILD_ZLIB=False
export BUILD_BZIP2=0
# configure
sh Configure -des -Dprefix=/usr   \
    -Dvendorprefix=/usr           \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager="/usr/bin/less -isR"  \
    -Duseshrplib                  \
    -Dusethreads
# compile, test, install
make
# several tests related to zlib will fail due to using the system
# version of zlib instead of the internal version
make -k test || true
make install
unset BUILD_ZLIB BUILD_BZIP2
# cleanup
popd \
  && rm -rf /tmp/perl
