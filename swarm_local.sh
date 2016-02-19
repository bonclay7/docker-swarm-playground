#!/bin/bash
# from https://raw.githubusercontent.com/bowwowxx/docker_swarm/master/swarm_local.sh

set -x

# echo "Removing old cluster"
# docker-machine rm -f swarm-master swarm-node1 swarm-node2 2> /dev/null


SWARM_NODES=2
SWARM_MEMORY=4096


docker-machine ip registry || {
  echo "Creating local docker registry machine"
  docker-machine create -d virtualbox registry

  echo "Launching docker registry cache service"
  docker $(docker-machine config registry) run -d -p 5000:5000 --name registry-mirror --restart=always \
      -v $(pwd)/registry/cache:/var/lib/registry/ \
     -v $(pwd)/registry/configuration/:/etc/registry/ \
     registry:2 /etc/registry/config.yml

  echo "Launching squid proxy on registry machine"
  docker $(docker-machine config registry) run -d --name squid --restart=always \
    -p 3128:3128 \
    -v $(pwd)/registry/proxy_cache:/var/spool/squid3 \
    sameersbn/squid:3.3.8-7
}

docker-machine ip consul || {
  echo "Creating consul machine"
  docker-machine create \
      -d virtualbox \
      --engine-registry-mirror http://$(docker-machine ip registry):5000 \
      --engine-insecure-registry registry-1.docker.io \
      consul

  echo "Launching consul machine"
  docker $(docker-machine config consul) run -d --restart=always \
      -p "8500:8500" \
      -h "consul" \
      progrium/consul -server -bootstrap
}

echo "Creating swarm-master"
docker-machine create \
    -d virtualbox \
    --virtualbox-memory $SWARM_MEMORY \
    --engine-registry-mirror http://$(docker-machine ip registry):5000 \
    --engine-insecure-registry registry-1.docker.io \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swarm-master

eval $(docker-machine env swarm-master)
docker run -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://$(docker-machine ip consul):8500

echo "Creating swarm nodes"
for i in $( seq 1 $SWARM_NODES ); do
  SWARM_NODE=$(echo swarm-node$i)
  docker-machine create \
      -d virtualbox \
      --virtualbox-memory $SWARM_MEMORY \
      --engine-registry-mirror http://$(docker-machine ip registry):5000 \
      --engine-insecure-registry registry-1.docker.io \
      --engine-env HTTP_PROXY=http://$(docker-machine ip registry):3128/ \
      --engine-env HTTPS_PROXY=http://$(docker-machine ip registry):3128/ \
      --engine-env FTP_PROXY=http://$(docker-machine ip registry):3128/ \
      --swarm \
      --swarm-discovery="consul://$(docker-machine ip consul):8500" \
      --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
      --engine-opt="cluster-advertise=eth1:0" \
      $SWARM_NODE

  eval $(docker-machine env $SWARM_NODE)

  echo "Launching registrator"
  docker run -d --restart=always \
      --name=registrator \
      --net=host \
      --volume=/var/run/docker.sock:/tmp/docker.sock \
      gliderlabs/registrator:latest \
      consul://$(docker-machine ip consul):8500
done

eval $(docker-machine env --swarm swarm-master)
docker network rm swarm-net
docker network create --driver overlay swarm-net

pushd ./services
export PROXY_IP=$(docker-machine ip registry)
docker-compose build
docker-compose up
popd

curl $(docker-machine ip consul):8500/v1/catalog/services | jq
# curl $(docker-machine ip consul):8500/v1/catalog/service/nginx-80
