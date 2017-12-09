#!/bin/bash
set -e
echo "Building linux kernel.."
echo "Approximate build time: 4.4 - 66.0 SBU (typically about 6 SBU)"
echo "Required disk space: 960 - 4250 MB (typically about 1100 MB)"

# 8.3. Linux package contains the Linux kernel
tar -xf /sources/linux-*.tar.xz -C /tmp/ \
  && mv /tmp/linux-* /tmp/linux \
  && pushd /tmp/linux

# ensure proper ownership of the files
chown -R 0:0 .

# 8.3.1 install kernel
# clean source tree
make mrproper
# copy premade config
# NOTE manual way is by launching:
# make menuconfig
cp /tools/kernel.config .config
# compile
make
# installation
make modules_install
# copy kernel image
cp -v arch/x86/boot/bzImage /boot/vmlinuz-4.12.7-lfs-8.1
# copy symbols
cp -v System.map /boot/System.map-4.12.7
# copy original configuration
cp -v .config /boot/config-4.12.7
# install documentation
install -d /usr/share/doc/linux-4.12.7
cp -r Documentation/* /usr/share/doc/linux-4.12.7

# 8.3.2. configure linux module load order
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
EOF

# cleanup
popd \
  && rm -rf /tmp/linux
