#!/bin/bash

if [ ! -f /opt/server_fqdn ]; then
  sed -i -- "s/hostname=localhost/hostname=${AMBARI_SERVER_FQDN}/g" /etc/ambari-agent/conf/ambari-agent.ini
  echo ${AMBARI_SERVER_FQDN} >> /opt/server_fqdn
  echo "set ambari server fqdn="${AMBARI_SERVER_FQDN}
fi

ambari-agent start && tail -f /var/log/ambari-agent/ambari-agent.log

