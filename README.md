## Description

This repository contains docker configuration to build bootable iso
image with [Linux From Scratch 8.2](http://www.linuxfromscratch.org/lfs/downloads/8.2/LFS-BOOK-8.2.pdf).

## Why

General idea is to learn Linux by building and running LFS system in
isolation from the host system.

## Structure

Scripts are organized in the way of following book structure whenever
it makes sense. Some deviations are done to make a bootable iso image.

## Build

Use the following command:

docker build --tag lfs:8.2 .
docker rm lfs; docker run -it --init --name lfs lfs:8.2

<!-- sudo docker cp lfs:/tmp/lfs.iso .
# Ramdisk you can find here: /tmp/ramdisk.img
 -->
<!-- in order to execute some commands (e.g. mount).
Please note, that extended privileges are required by docker container
 -->
<!-- ## Usage

Final result is bootable iso image with LFS system which, for
example, can be used to load the system inside virtual machine (tested
with VirtualBox).
 -->
## License

This work is based on instructions from [Linux from Scratch](http://www.linuxfromscratch.org/lfs)
project and provided with MIT license.
