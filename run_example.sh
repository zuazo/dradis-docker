#!/bin/sh

mkdir -p dbdata/

docker run \
  -ti \
  -p 3000:3000 \
  --volume "$(pwd)/dbdata:/dbdata" \
  --env SECRET_KEY_BASE=AUdFs63SE6Txd7dNqRo1 \
  zuazo/dradis "${@}"
