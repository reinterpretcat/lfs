![LFS in Virtual Machines](https://github.com/numberformat/lfs/releases/download/v8.2.1/Screenshot.2024-04-13.at.8.30.00.PM.png)

## Description

This repository contains docker configuration to build bootable ISO image with [Linux From Scratch 8.2](http://www.linuxfromscratch.org/lfs/downloads/8.2/LFS-BOOK-8.2.pdf).

## Why

General idea is to learn Linux by building and running LFS system in
isolation from the host system.

## Structure

Scripts are organized in the way of following book structure whenever
it makes sense. Some deviations are done to make a bootable iso image.

## Build

Use the following commands:

```sh
sudo ./phase1.sh
sudo ./phase2.sh # If you get an error losetup: /tmp/ramdisk: failed to set up loop device, then just retry.
```

Please note, that extended privileges are required by docker container
in order to execute some commands (e.g. mount).

## Usage

Final result is bootable iso image with LFS system which, for example, can be used to load the system inside virtual machine (tested
with VirtualBox and Proxmox VE).

Below is a screenshot of the files contained within the ISO image. The image is bootable using Proxmox VE, VirtualBox or any other Virtual Environment.

![LFS in Virtual Machines](https://github.com/numberformat/lfs/releases/download/v8.2.1/Screenshot.2024-04-13.at.8.41.03.PM.png)

It uses RAMDisk thus does not require you to install it into any partition. The please note that your changes will be lost when the VM is restarted. To get around it you can just mount a SMB or NFS share and save your data there.

## Troubleshooting

If you have problems with master branch, please try to use stable version from the latest release with toolchain from archive.

## License

This work is based on instructions from [Linux from Scratch](http://www.linuxfromscratch.org/lfs)
project and provided with MIT license.
