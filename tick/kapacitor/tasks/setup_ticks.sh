#!/bin/bash
kapacitor define -name cpu_usage -type stream -dbrp telemetry.default -tick  /etc/kapacitor/tasks/cpu_usage.tick
kapacitor enable cpu_usage
