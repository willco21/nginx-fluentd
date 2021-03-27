#!/bin/bash -ex

docker build .  --tag nginx-fluentd
docker run -it --rm -p 80:80 nginx-fluentd