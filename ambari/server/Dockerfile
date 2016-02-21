FROM ubuntu:trusty

ENV PROXY_HOST ""
ENV PROXY_PORT ""

RUN echo "deb http://public-repo-1.hortonworks.com/ambari/debian7/2.x/updates/2.2.0.0 Ambari main" > /etc/apt/sources.list.d/ambari.list
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update
RUN apt-get -y install ambari-server
RUN apt-get clean

EXPOSE 8080
CMD cat /var/lib/ambari-server/ambari-env.sh && echo "" >> /var/lib/ambari-server/ambari-env.sh \
	&& echo "export 'AMBARI_JVM_ARGS=$AMBARI_JVM_ARGS -Dhttp.proxyHost=${PROXY_HOST} -Dhttp.proxyPort=${PROXY_PORT}'" >> /var/lib/ambari-server/ambari-env.sh \ 
	&& ambari-server setup --silent \
	&& ambari-server start \
	&& tail -f /var/log/ambari-server/ambari-server.log

