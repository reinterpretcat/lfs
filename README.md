![LFS in VirtualBox](https://user-images.githubusercontent.com/1611077/33808510-16825dd2-dde8-11e7-9a1c-0ca0bc3ff2b5.png)

## Description

This repository contains docker configuration to build LFS system currently based on [LFS book version 8.1](http://www.linuxfromscratch.org/lfs/downloads/8.1/LFS-BOOK-8.1.pdf). In general, Dockerfile builds an image with instructions from the __"Preparing for the Build"__ part of the LFS book. When container is created from the image, it launches script with instructions from __"Building the LFS System"__ part.

## Status

Work in progress: repository will be updated according my progress with LFS book.

## Structure

Scripts are organized in the way of following book structure whenever it makes sense. Some deviations are done to make a bootable iso image.

## Build

With docker compose:

    # build image
    docker build --tag lfs .
    # run container
    sudo docker run -it --privileged --name lfs lfs
    # TODO copy iso image to host
    sudo docker cp lfs:/home/tools/lfs.iso .

Be patient as it takes time. Please note, that extended privileges are required by docker container in order to execute some commands (e.g. mount).

## Usage

Final result is bootable iso image with LFS system which, for example, can be used to load the system inside virtual machine (tested with VirtualBox). This differs from then LFS system built by following book's instructions strictly.

## License

This work is based on instructions from [Linux from Scratch](http://www.linuxfromscratch.org/lfs) project and provided with MIT license.
