#!/bin/bash
mkdir -p workdir
docker run -h alphanine --rm -it -u "$UID:$(id -g)" -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v "$(pwd)/home":/home/$USER -v "$(pwd)/workdir":/z alphacloud fish

