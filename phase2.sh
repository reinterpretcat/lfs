#!/bin/bash
set -e

docker rm lfs_final > /dev/null 2>&1 || true
docker commit lfs_phase1 lfs_phase2    # convert phase 1 container into phase 2 image
docker build --tag lfs_final -f Dockerfile2 . # this dockerfile creates phase2 image from FROM the lfs_phase2
docker run -it --privileged --name lfs_final lfs_final # this creates the final container
docker cp lfs_final:/tmp/lfs.iso . # copy all the necessary files out of final container