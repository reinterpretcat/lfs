![LFS in VirtualBox](https://user-images.githubusercontent.com/1611077/33808510-16825dd2-dde8-11e7-9a1c-0ca0bc3ff2b5.png)

## Description

This repository contains docker configuration to build LFS system currently based on [LFS book version 8.1](http://www.linuxfromscratch.org/lfs/downloads/8.1/LFS-BOOK-8.1.pdf).

## Status

Work in progress.

## Structure

Scripts are organized in the way of following book structure whenever it makes sense. Some deviations are done to make a bootable iso image.

## Build

Use the following command:

    docker rm lfs ;                                    \
    docker build --tag lfs . &&                        \
    sudo docker run -it --privileged --name lfs lfs && \
    docker cp lfs:/tmp/lfs.iso .

Please note, that extended privileges are required by docker container in order to execute some commands (e.g. mount).

## Usage

Final result is bootable iso image with LFS system which, for example, can be used to load the system inside virtual machine (tested with VirtualBox). This differs from then LFS system built by following book's instructions strictly.

## License

This work is based on instructions from [Linux from Scratch](http://www.linuxfromscratch.org/lfs) project and provided with MIT license.
