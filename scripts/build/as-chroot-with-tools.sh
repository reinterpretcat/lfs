#!/bin/bash
set -e
echo "Continue with chroot environment.."
. /tools/.variables

# SKIP remove the "I have no name!" promp
# exec /tools/bin/bash --login +h

# build toolchain
/tools/6.5-create-directories.sh
/tools/6.6-create-essentials.sh
/tools/6.7-make-linux-api-headers.sh
/tools/6.8-make-man-pages.sh
/tools/6.9-make-glibc.sh
/tools/6.10-adjust-toolchain.sh
/tools/6.11-make-zlib.sh
/tools/6.12-make-file.sh
/tools/6.13-make-readline.sh
/tools/6.14-make-m4.sh
/tools/6.15-make-bc.sh
/tools/6.16-make-binutils.sh
/tools/6.17-make-gmp.sh
/tools/6.18-make-mpfr.sh
/tools/6.19-make-mpc.sh
/tools/6.20-make-gcc.sh
/tools/6.21-make-bzip2.sh
/tools/6.22-make-pkg-config.sh
/tools/6.23-make-ncurses.sh
/tools/6.24-make-attr.sh
/tools/6.25-make-acl.sh
/tools/6.26-make-libcap.sh
/tools/6.27-make-sed.sh
/tools/6.28-make-shadow.sh
/tools/6.29-make-psmisc.sh
/tools/6.30-make-iana-etc.sh
/tools/6.31-make-bison.sh
/tools/6.32-make-flex.sh
/tools/6.33-make-grep.sh
/tools/6.34-make-bash.sh

# SKIP switching to built bash
#exec /bin/bash --login +h

/tools/6.35-make-libtool.sh
/tools/6.36-make-gdbm.sh
/tools/6.37-make-gperf.sh
/tools/6.38-make-expat.sh
/tools/6.39-make-inetutils.sh
/tools/6.40-make-perl.sh
/tools/6.41-make-xml-parser.sh
/tools/6.42-make-intltool.sh
/tools/6.43-make-autoconf.sh
/tools/6.44-make-automake.sh
/tools/6.45-make-xz.sh
/tools/6.46-make-kmod.sh
/tools/6.47-make-gettext.sh
/tools/6.48-make-procps-ng.sh
/tools/6.49-make-e2fsprogs.sh
/tools/6.50-make-coreutils.sh
/tools/6.51-make-diffutils.sh
/tools/6.52-make-gawk.sh
/tools/6.53-make-findutils.sh
/tools/6.54-make-groff.sh
/tools/6.55-make-grub.sh
/tools/6.56-make-less.sh
/tools/6.57-make-gzip.sh
/tools/6.58-make-iproute2.sh
/tools/6.59-make-kbd.sh
/tools/6.60-make-libpipeline.sh
/tools/6.61-make-make.sh
/tools/6.62-make-patch.sh
/tools/6.63-make-sysklogd.sh
/tools/6.64-make-sysvinit.sh
/tools/6.65-make-eudev.sh
/tools/6.66-make-util-linux.sh
/tools/6.67-make-man-db.sh
/tools/6.68-make-tar.sh
/tools/6.69-make-texinfo.sh
/tools/6.70-make-vim.sh
/tools/6.71-strip.sh
/tools/6.72-clean.sh

exit
