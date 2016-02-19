#!/bin/bash
# from https://raw.githubusercontent.com/bowwowxx/docker_swarm/master/swarm_local.sh

set -x

# echo "Removing old cluster"
# docker-machine rm -f swarm-master swarm-node1 swarm-node2 2> /dev/null


SWARM_NODES=2
AMBARI_NODES=3
SWARM_MEMORY=4096


docker-machine ip registry || {
  echo "Creating local docker registry machine"
  docker-machine create -d virtualbox registry
  eval $(docker-machine env registry)

  echo "Creating shared volume"
  docker create -v /cache --name cache ubuntu
  docker run --rm -it --volumes-from cache ubuntu chmod -R 777 /cache

  echo "Launching docker registry cache service"
  docker run -d -p 5000:5000 --name registry-mirror --restart=always \
     --volumes-from cache \
     -v $(pwd)/registry/config.yml:/etc/registry/config.yml \
     registry:2 /etc/registry/config.yml

  echo "Launching squid proxy on registry machine"
  docker run -d --name squid --restart=always \
    -p 3128:3128 \
    --volumes-from cache \
    -v $(pwd)/proxy/squid.conf:/etc/squid3/squid.conf \
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
docker network inspect swarm-net && docker network rm swarm-net
docker network create --driver overlay swarm-net

pushd ./services
export PROXY_IP=$(docker-machine ip registry)
docker-compose build
docker-compose up
popd

echo "Run ambari master"
docker run -d --restart=always \
  --hostname=ambari-master.swarm-net \
  --name=ambari-master \
  --net=swarm-net \
  -p 8080 \
  whylu/docker-ambari:server

for i in $( seq 1 $AMBARI_NODES ); do
  echo "Run ambari node $i"
  docker run -d --restart=always \
    -e SERVER_FQDN=ambari-master.swarm-net \
    --hostname=ambari-node$i.swarm-net \
    --name=ambari-node$i \
    --net=swarm-net \
    whylu/docker-ambari:agent
done

curl $(docker-machine ip consul):8500/v1/catalog/services | jq
# curl $(docker-machine ip consul):8500/v1/catalog/service/nginx-80
