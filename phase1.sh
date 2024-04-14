#!/bin/bash
set -e

docker rm lfs_phase1 > /dev/null 2>&1 || true
docker image rm lfs_phase1 > /dev/null 2>&1 || true
docker build --tag lfs_phase1 .
# this performs the privileged build to create the phase1 container
docker run -it --privileged --name lfs_phase1 lfs_phase1 
