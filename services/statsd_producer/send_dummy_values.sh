#!/bin/bash
while true; do
  dummyValue="example:$((RANDOM % 100))|c"
  echo -n "$dummyValue" | nc -w 1 -u statsd 8125;
  echo "Sending $dummyValue to statsd"
  sleep 5
done

