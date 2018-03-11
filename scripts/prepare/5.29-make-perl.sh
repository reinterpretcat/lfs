#!/bin/bash
set -e
echo "Building perl.."
echo "Approximate build time: 1.3 SBU"
echo "Required disk space: 261 MB"

# 5.30. Perl package contains the Practical Extraction and Report Language
tar -xf perl-5*.tar.xz -C /tmp/ \
  && mv /tmp/perl-* /tmp/perl \
  && pushd /tmp/perl

# Prepare Perl for compilation:
sh Configure -des -Dprefix=/tools -Dlibs=-lm

# Build the package:
make

# Only a few of the utilities and libraries need to be installed at this time:
cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.26.1
cp -Rv lib/* /tools/lib/perl5/5.26.1

popd \
  && rm -rf /tmp/perl
