#!/bin/bash

curl -G http://influxdb:8086/query --data-urlencode "q=CREATE DATABASE telemetry"
diamond -f -l --skip-pidfile -c diamond.conf
