#!/bin/bash -ex

docker build . -f base-nginx.dockerfile --tag base-nginx
docker run -it --rm -p 80:80 base-nginx