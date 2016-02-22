#!/bin/bash

eval $(docker-machine env --swarm swarm-master)

pushd ./tick
export PROXY_IP=$(docker-machine ip tools)
docker-compose build
docker-compose up
popd

echo Setup tasks
docker exec -t $(docker ps | grep tick_kapacitor | awk '{print $1}') /etc/kapacitor/tasks/setup_ticks.sh

