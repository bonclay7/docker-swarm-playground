FROM ubuntu:trusty

ENV PROXY_HOST ""
ENV PROXY_PORT ""
ENV AMBARI_SERVER_FQDN ""

RUN echo "deb http://public-repo-1.hortonworks.com/ambari/debian7/2.x/updates/2.2.0.0 Ambari main" > /etc/apt/sources.list.d/ambari.list
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update
RUN apt-get -y install ambari-agent
RUN apt-get clean

ADD ./start_agent.sh /tmp/start_agent.sh
RUN chmod +x /tmp/start_agent.sh
CMD /bin/bash -c "/tmp/start_agent.sh"

