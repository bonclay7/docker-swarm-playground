#!/bin/bash
# from https://raw.githubusercontent.com/bowwowxx/docker_swarm/master/swarm_local.sh
set -e

docker-machine ip registry || { 
	echo "Creating local docker registry machine"
	docker-machine create -d virtualbox registry

	echo "Launching docker registry cache service"
	docker $(docker-machine config registry) run -d -p 5000:5000 --name registry-mirror \
 	   -v $(pwd)/registry/cache:/var/lib/registry/ \
		 -v $(pwd)/registry/configuration/:/etc/registry/ \
		 registry:2 /etc/registry/config.yml	
}

docker-machine ip consul || {
	echo "Creating consul machine"
	docker-machine create \
  		-d virtualbox \
			--engine-registry-mirror http://$(docker-machine ip registry):5000 \
			--engine-insecure-registry registry-1.docker.io \
			consul

	echo "Launching consul machine"
	docker $(docker-machine config consul) run -d \
	    -p "8500:8500" \
	    -h "consul" \
	    progrium/consul -server -bootstrap
}

echo "Removing old cluster"
docker-machine rm -f swarm-master swarm-node1 swarm-node2 2> /dev/null

echo "Creating swarm-master"
docker-machine create \
    -d virtualbox \
		--engine-registry-mirror http://$(docker-machine ip registry):5000 \
		--engine-insecure-registry registry-1.docker.io \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swarm-master

echo "Creating swarm-node1"
docker-machine create \
    -d virtualbox \
		--engine-registry-mirror http://$(docker-machine ip registry):5000 \
		--engine-insecure-registry registry-1.docker.io \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swarm-node1

echo "Creating swarm-node2"
docker-machine create \
    -d virtualbox \
		--engine-registry-mirror http://$(docker-machine ip registry):5000 \
		--engine-insecure-registry registry-1.docker.io \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swarm-node2


echo "Launching orchestrator"
eval $(docker-machine env swarm-master)
docker rm -f registrator
docker run -d \
    --name=registrator \
	  --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://$(docker-machine ip consul):8500

eval $(docker-machine env swarm-node1)
docker rm -f registrator
docker run -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://$(docker-machine ip consul):8500

eval $(docker-machine env swarm-node2)
docker rm -f registrator
docker run -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://$(docker-machine ip consul):8500


eval $(docker-machine env --swarm swarm-master)
docker network create --driver overlay swarm-net

docker run -itd -P --name=web1 --net=swarm-net nginx
docker run -itd -P --name=web2 --net=swarm-net nginx
docker run -itd -P --name=web3 --net=swarm-net nginx
docker run -itd -P --name=web4 --net=swarm-net nginx
docker run -it --net=swarm-net busybox wget -O- http://web1
docker run -it --net=swarm-net busybox wget -O- http://web2
docker run -it --net=swarm-net busybox wget -O- http://web3
docker run -it --net=swarm-net busybox wget -O- http://web4

curl $(docker-machine ip consul):8500/v1/catalog/services
curl $(docker-machine ip consul):8500/v1/catalog/service/nginx-80
