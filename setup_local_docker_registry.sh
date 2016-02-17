#!/bin/bash

set -e

docker-machine create -d virtualbox registry

eval $(docker-machine env registry)

docker run -d -p 5000:5000 --name registry-mirror \
  -v $(pwd)/registry/cache:/var/lib/registry/ \
	-v $(pwd)/registry/configuration/:/etc/registry/ \
	registry:2 /etc/registry/config.yml