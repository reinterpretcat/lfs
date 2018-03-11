#!/bin/bash
set -e
echo "Preparing environment.."

# download toolchain
sh /tools/3.1-download-tools.sh

# build toolchain
sh /tools/5.4-make-binutils.sh
sh /tools/5.5-make-gcc.sh
sh /tools/5.6-make-linux-api-headers.sh
sh /tools/5.7-make-glibc.sh
sh /tools/5.8-make-libstdc.sh
sh /tools/5.9-make-binutils.sh
sh /tools/5.10-make-gcc.sh
sh /tools/5.11-make-tcl.sh
sh /tools/5.12-make-expect.sh
sh /tools/5.13-make-dejagnu.sh
sh /tools/5.14-make-m4.sh
sh /tools/5.15-make-ncurses.sh
sh /tools/5.16-make-bash.sh
sh /tools/5.17-make-bison.sh
sh /tools/5.18-make-bzip2.sh
sh /tools/5.19-make-coreutils.sh
sh /tools/5.20-make-diffutils.sh
sh /tools/5.21-make-file.sh
sh /tools/5.22-make-findutils.sh
sh /tools/5.23-make-gawk.sh
sh /tools/5.24-make-gettext.sh
sh /tools/5.25-make-grep.sh
sh /tools/5.26-make-gzip.sh
sh /tools/5.27-make-make.sh
sh /tools/5.28-make-patch.sh
sh /tools/5.29-make-perl.sh
sh /tools/5.30-make-sed.sh
sh /tools/5.31-make-tar.sh
sh /tools/5.32-make-texinfo.sh
sh /tools/5.33-make-util-linux.sh
sh /tools/5.34-make-xz.sh
sh /tools/5.35-strip.sh
