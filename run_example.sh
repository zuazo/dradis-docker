#!/bin/sh

mkdir -p dbdata/

docker run \
  -p 3000:3000 \
  --volume "$(pwd)/dbdata:/dbdata" \
  zuazo/dradis "${@}"
