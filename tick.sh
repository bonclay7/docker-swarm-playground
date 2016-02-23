#!/bin/bash

eval $(docker-machine env --swarm swarm-master)

echo "Cleanup old containters"
docker ps -a |grep tick|awk '{print $1}'|xargs docker rm -f

pushd ./tick
export PROXY_IP=$(docker-machine ip tools)
#docker-compose build
docker-compose up -d
popd

echo Setup tasks
docker exec -t $(docker ps | grep tick_kapacitor | awk '{print $1}') /etc/kapacitor/tasks/setup_ticks.sh

echo "Using grafana api for further configurations"
docker exec -t $(docker ps | grep tick_grafana | awk '{print $1}') /etc/grafana/api-client.sh
