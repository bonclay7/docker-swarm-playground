FROM debian:latest

RUN apt-get update 
RUN apt-get install -y collectd

EXPOSE 80

ADD collectd.conf /etc/collectd/collectd.conf 
ADD ./run.sh /run.sh

ENTRYPOINT ["/run.sh"]
