#!/bin/bash
set -e
echo "Continue with chroot environment.."

# SKIP remove the "I have no name!" promp
# exec /tools/bin/bash --login +h

# build toolchain
sh /tools/6.5-create-directories.sh
sh /tools/6.6-create-essentials.sh
sh /tools/6.7-make-linux-api-headers.sh
sh /tools/6.8-make-man-pages.sh
sh /tools/6.9-make-glibc.sh
sh /tools/6.10-adjust-toolchain.sh
sh /tools/6.11-make-zlib.sh
sh /tools/6.12-make-file.sh
sh /tools/6.13-make-readline.sh
sh /tools/6.14-make-m4.sh
sh /tools/6.15-make-bc.sh
sh /tools/6.16-make-binutils.sh
sh /tools/6.17-make-gmp.sh
sh /tools/6.18-make-mpfr.sh
sh /tools/6.19-make-mpc.sh
sh /tools/6.20-make-gcc.sh
sh /tools/6.21-make-bzip2.sh
sh /tools/6.22-make-pkg-config.sh
sh /tools/6.23-make-ncurses.sh
sh /tools/6.24-make-attr.sh
sh /tools/6.25-make-acl.sh
sh /tools/6.26-make-libcap.sh
sh /tools/6.27-make-sed.sh
sh /tools/6.28-make-shadow.sh
sh /tools/6.29-make-psmisc.sh
sh /tools/6.30-make-iana-etc.sh
sh /tools/6.31-make-bison.sh
sh /tools/6.32-make-flex.sh
sh /tools/6.33-make-grep.sh
sh /tools/6.34-make-bash.sh
sh /tools/6.35-make-libtool.sh
sh /tools/6.36-make-gdbm.sh
sh /tools/6.37-make-gperf.sh
sh /tools/6.38-make-expat.sh
sh /tools/6.39-make-inetutils.sh
sh /tools/6.40-make-perl.sh
sh /tools/6.41-make-xml-parser.sh
sh /tools/6.42-make-intltool.sh

# SKIP switching to built bash
#exec /bin/bash --login +h

sh /tools/6.35-make-libtool.sh
sh /tools/6.36-make-gdbm.sh
