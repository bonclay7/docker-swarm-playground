#!/bin/bash
# from https://raw.githubusercontent.com/bowwowxx/docker_swarm/master/swarm_local.sh
set -e

docker-machine ip registry || { 
	echo "Creating local docker registry"
	sh $(pwd)/setup_local_docker_registry.sh
}

docker-machine create \
    -d virtualbox \
		--engine-registry-mirror http://$(docker-machine ip registry):5000 \
		--engine-insecure-registry registry-1.docker.io \
    swl-consul

docker $(docker-machine config swl-consul) run -d \
    -p "8500:8500" \
    -h "consul" \
    progrium/consul -server -bootstrap

docker-machine create \
    -d virtualbox \
		--engine-registry-mirror http://$(docker-machine ip registry):5000 \
		--engine-insecure-registry registry-1.docker.io \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swl-demo0

docker-machine create \
    -d virtualbox \
		--engine-registry-mirror http://$(docker-machine ip registry):5000 \
		--engine-insecure-registry registry-1.docker.io \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swl-demo1

docker-machine create \
    -d virtualbox \
		--engine-registry-mirror http://$(docker-machine ip registry):5000 \
		--engine-insecure-registry registry-1.docker.io \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swl-demo2

eval $(docker-machine env --swarm swl-demo0)
docker network create --driver overlay bowwow-net

docker run -itd --name=webtest --net=bowwow-net --env="constraint:node==swl-demo1" nginx
docker run -it --net=bowwow-net --env="constraint:node==swl-demo2" busybox wget -O- http://webtest