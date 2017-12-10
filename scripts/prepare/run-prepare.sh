#!/bin/bash
set -e
echo "Preparing environment.."
. /tools/.variables

# download toolchain
/tools/3.1-download-tools.sh

# build toolchain
/tools/5.4-make-binutils.sh
/tools/5.5-make-gcc.sh
/tools/5.6-make-linux-api-headers.sh
/tools/5.7-make-glibc.sh
/tools/5.8-make-libstdc.sh
/tools/5.9-make-binutils.sh
/tools/5.10-make-gcc.sh
/tools/5.11-make-tcl.sh
/tools/5.12-make-expect.sh
/tools/5.13-make-dejagnu.sh
/tools/5.14-make-check.sh
/tools/5.15-make-ncurses.sh
/tools/5.16-make-bash.sh
/tools/5.17-make-bison.sh
/tools/5.18-make-bzip2.sh
/tools/5.19-make-coreutils.sh
/tools/5.20-make-diffutils.sh
/tools/5.21-make-file.sh
/tools/5.22-make-findutils.sh
/tools/5.23-make-gawk.sh
/tools/5.24-make-gettext.sh
/tools/5.25-make-grep.sh
/tools/5.26-make-gzip.sh
/tools/5.27-make-m4.sh
/tools/5.28-make-make.sh
/tools/5.29-make-patch.sh
/tools/5.30-make-perl.sh
/tools/5.31-make-sed.sh
/tools/5.32-make-tar.sh
/tools/5.33-make-texinfo.sh
/tools/5.34-make-util-linux.sh
/tools/5.35-make-xz.sh
/tools/5.36-strip.sh
