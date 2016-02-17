#!/bin/bash
# from https://github.com/bowwowxx/docker_swarm/blob/master/swarm_local.sh

# clean before run
docker-machine rm swarm-zookeeper swarm-master swarm-node1 swarm-node2 2> /dev/null

set -e

docker-machine create \
    -d virtualbox \
    swarm-zookeeper

docker $(docker-machine config swarm-zookeeper) run -d \
    -p "2181:2181" \
    -p "2888:2888" \
    -p "3888:3888" \
    -h "zookeeper" \
    jplock/zookeeper

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-master \
    --swarm-discovery="zk://$(docker-machine ip swarm-zookeeper):2181" \
    --engine-opt="cluster-store=zk://$(docker-machine ip swarm-zookeeper):2181" \
    --engine-opt="cluster-advertise=eth1:0" \
    swarm-master

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery="zk://$(docker-machine ip swarm-zookeeper):2181" \
    --engine-opt="cluster-store=zk://$(docker-machine ip swarm-zookeeper):2181" \
    --engine-opt="cluster-advertise=eth1:0" \
    swarm-node1

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery="zk://$(docker-machine ip swarm-zookeeper):2181" \
    --engine-opt="cluster-store=zk://$(docker-machine ip swarm-zookeeper):2181" \
    --engine-opt="cluster-advertise=eth1:0" \
    swarm-node2

eval $(docker-machine env --swarm swarm-master)
docker network create --driver overlay swarm-net

docker run -itd --name=webtest --net=swarm-net --env="constraint:node==swarm-node1" nginx
docker run -it --net=swarm-net --env="constraint:node==swarm-node2" busybox wget -O- http://webtest
