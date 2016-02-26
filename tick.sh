#!/bin/bash

set -e

echo "Using swarm cluster environment"
eval $(docker-machine env --swarm swarm-master)
export PROXY_IP=$(docker-machine ip tools)
export ZOOKEEPER_IP=$(docker-machine ip tools)

echo "Cleanup old containters"
docker ps -a |grep tick|awk '{print $1}'|xargs docker rm -f

pushd ./tick
echo "Building images"
docker-compose build
echo "Running images"
docker-compose up -d
popd

kapacitor_container=$(docker ps | grep tick_kapacitor | awk '{print $1}')
grafana_container=$(docker ps | grep tick_grafana | awk '{print $1}')
influxdb_container=$(docker ps | grep tick_influxdb | awk '{print $1}')
chronograf_container=$(docker ps | grep tick_chronograf | awk '{print $1}')

influxdb_ip=$(docker inspect --format '{{ .Node.IP }}' $influxdb_container)
chronograf_ip=$(docker inspect --format '{{ .Node.IP }}' $chronograf_container)


echo "Setup tasks"
docker exec -t $kapacitor_container /etc/kapacitor/tasks/setup_ticks.sh

echo "Using grafana api for further configurations"
docker exec -t $grafana_container /etc/grafana/api-client.sh

echo "Setup influxdb in chronograph"
echo '{"id":1,"name":"influxdb","url":"http://'$influxdb_ip':8086"}' | curl -d @- "http://$chronograf_ip:10000/api/v0/servers"


open "http://$chronograf_ip:10000/"
