FROM ubuntu:trusty

ENV PROXY_HOST ""
ENV PROXY_PORT ""
ENV AMBARI_SERVER_FQDN ""

RUN echo "deb http://public-repo-1.hortonworks.com/ambari/debian7/2.x/updates/2.2.0.0 Ambari main" > /etc/apt/sources.list.d/ambari.list
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update
RUN apt-get -y install ambari-agent
RUN apt-get clean

## Influxdb
RUN apt-get -y install curl apt-transport-https && curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
RUN bash -c 'source /etc/lsb-release && echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list'
RUN apt-get update


ADD ./start_agent.sh /tmp/start_agent.sh
RUN chmod +x /tmp/start_agent.sh
CMD /bin/bash -c "/tmp/start_agent.sh"

