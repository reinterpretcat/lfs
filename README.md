## Description

This repository contains docker configuration to build LFS system currently based on [LFS book version 8.1](http://www.linuxfromscratch.org/lfs/downloads/8.1/LFS-BOOK-8.1.pdf). In general, Dockerfile builds an image with instructions from the __"Preparing for the Build"__ part of the LFS book. When container is created from the image, it launches script with instructions from __"Building the LFS System"__ part.

## Status

Work in progress: repository will be updated according my progress with LFS book.

## Build

With docker compose:

    sudo docker-compose up

Be patient as it takes time. You might consider to increase parallelism by tweaking __JOB_COUNT__ param. Please note, that extended privileges are required by docker container in order to execute some commands (e.g. mount).

## License

This work is based on instructions from [Linux from Scratch](http://www.linuxfromscratch.org/lfs) project and provided with MIT license.
