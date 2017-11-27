#!/bin/bash
set -e
echo "Building perl.."
echo "Approximate build time: 1.3 SBU"
echo "Required disk space: 261 MB"

# 5.30. Perl package contains the Practical Extraction and Report Language
tar -xf perl-5*.tar.xz -C /tmp/ \
  && mv /tmp/perl-* /tmp/perl \
  && pushd /tmp/perl \
  && sed -e '9751 a#ifndef PERL_IN_XSUB_RE' \
        -e '9808 a#endif' \
        -i regexec.c \
  && sh Configure -des -Dprefix=/tools -Dlibs=-lm \
  && make \
  && cp -v perl cpan/podlators/scripts/pod2man /tools/bin \
  && mkdir -pv /tools/lib/perl5/5.26.0 \
  && cp -Rv lib/* /tools/lib/perl5/5.26.0 \
  && popd \
  && rm -rf /tmp/perl
