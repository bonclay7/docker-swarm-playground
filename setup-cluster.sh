#!/bin/bash

set -x

REGISTRY_DISK_SIZE=30000
SWARM_NODES=2
SWARM_CPU=4
SWARM_MEMORY=4096

docker-machine ip tools || {
  echo "Creating tools machine"

  docker-machine create -d virtualbox --virtualbox-disk-size $REGISTRY_DISK_SIZE tools
  eval $(docker-machine env tools)

  echo "Creating shared volume"
  docker create -v /cache --name cache ubuntu
  echo "configuring shared volume"
  docker run --rm -it --volumes-from cache ubuntu mkdir -p /cache/registry
  docker run --rm -it --volumes-from cache ubuntu chmod -R 777 /cache

  echo "Launching docker registry service on tools machine"
  docker run -d -p 5000:5000 \
     --name registry \
     --restart=always \
     --volumes-from cache \
     -v $(pwd)/registry/config.yml:/etc/registry/config.yml \
     registry:2.3.0 /etc/registry/config.yml

  echo "Launching squid proxy on tools machine"
  docker run -d \
    --name squid \
    --restart=always \
    -p 3128:3128 \
    --volumes-from cache \
    -v $(pwd)/proxy/squid.conf:/etc/squid3/squid.conf \
    sameersbn/squid:3.3.8-7

  docker run -d --restart=always \
      --name consul \
      -p 8400:8400 \
      -p 8500:8500 \
      -p 8600:53/udp \
      -h consul \
      gliderlabs/consul-server -server -bootstrap

  echo "Launching zookeeper on tools machine"
  docker run -d --restart=always\
      --name zookeeper \
      -p 2181:2181 \
      jplock/zookeeper
}

export TOOLS_IP=$(docker-machine inspect --format '{{ .Driver.IPAddress }}' tools)

export CONSUL=consul://${TOOLS_IP}:8500
export REGISTRY=http://${TOOLS_IP}:5000
export HTTP_PROXY=http://${TOOLS_IP}:3128
export HTTPS_PROXY=http://${TOOLS_IP}:3128
export FTP_PROXY=http://${TOOLS_IP}:3128
export NO_PROXY=${TOOLS_IP},localhost,127.0.0.1

echo "Creating swarm-master"
docker-machine create \
    -d virtualbox \
    --virtualbox-memory $SWARM_MEMORY \
    --virtualbox-cpu-count $SWARM_CPU \
    --engine-registry-mirror $REGISTRY \
    --engine-insecure-registry registry-1.docker.io \
    --swarm \
    --swarm-master \
    --swarm-discovery="$CONSUL" \
    --engine-opt="cluster-store=$CONSUL" \
    --engine-opt="cluster-advertise=eth1:0" \
    --engine-env HTTP_PROXY=${HTTP_PROXY} \
    --engine-env HTTPS_PROXY=${HTTPS_PROXY} \
    --engine-env FTP_PROXY=${FTP_PROXY} \
    --engine-env NO_PROXY=${NO_PROXY} \
    swarm-master

eval $(docker-machine env swarm-master)
docker run -d \
    --restart=always \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    $CONSUL

echo "Creating swarm nodes"
for i in $( seq 1 $SWARM_NODES ); do
  SWARM_NODE=$(echo swarm-node$i)
  docker-machine create \
      -d virtualbox \
      --virtualbox-memory $SWARM_MEMORY \
      --virtualbox-cpu-count $SWARM_CPU \
      --engine-registry-mirror $REGISTRY \
      --engine-insecure-registry registry-1.docker.io \
      --engine-env HTTP_PROXY=${HTTP_PROXY} \
      --engine-env HTTPS_PROXY=${HTTPS_PROXY} \
      --engine-env FTP_PROXY=${FTP_PROXY} \
      --engine-env NO_PROXY=${NO_PROXY} \
      --swarm \
      --swarm-discovery="$CONSUL" \
      --engine-opt="cluster-store=$CONSUL" \
      --engine-opt="cluster-advertise=eth1:0" \
      $SWARM_NODE

  eval $(docker-machine env $SWARM_NODE)

  echo "Launching registrator"
  docker run -d --restart=always \
      --name=registrator \
      --net=host \
      --volume=/var/run/docker.sock:/tmp/docker.sock \
      gliderlabs/registrator:latest \
      $CONSUL
done

eval $(docker-machine env --swarm swarm-master)
docker network inspect swarm-net && docker network rm swarm-net
docker network create --driver overlay swarm-net

curl -s $TOOLS_IP/v1/catalog/services | jq
