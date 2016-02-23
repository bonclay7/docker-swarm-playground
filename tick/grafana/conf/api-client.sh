#!/bin/bash

# Plug influxdb as a grafana datasource
curl -vs -H 'Content-Type: application/json' -XPOST -d \
	'{"name":"influxdb","type":"influxdb","url":"http://influxdb:8086","user":"root","password":"root","database":"telemetry", "access":"proxy"}' \
	http://admin:admin@grafana:3000/api/datasources