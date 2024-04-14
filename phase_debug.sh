#!/bin/bash
set -e

docker commit lfs_phase3 lfs_phase3
cat << EOF > Dockerfile_debug
FROM lfs_phase3:latest
ENTRYPOINT [ "/bin/bash" ]
EOF

docker build -t dockerfile_debug -f Dockerfile_debug . && \
docker run --rm -it dockerfile_debug
