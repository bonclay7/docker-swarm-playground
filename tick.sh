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

echo "Setup influxdb in chronograph"
influxdb_container=$(docker ps | grep tick_influxdb | awk '{print $1}')
influxdb_ip=$(docker inspect --format '{{ .Node.IP }}' $influxdb_container)

chronograf_container=$(docker ps | grep tick_chronograf | awk '{print $1}')
chronograf_ip=$(docker inspect --format '{{ .Node.IP }}' $chronograf_container)

echo '{"id":1,"name":"influxdb","url":"http://'$influxdb_ip':8086"}' | curl -d @- "http://$chronograf_ip:10000/api/v0/servers"
