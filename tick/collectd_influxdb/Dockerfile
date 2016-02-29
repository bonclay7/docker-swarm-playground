FROM debian:latest

RUN apt-get update 
RUN apt-get install -y collectd

ADD collectd.conf /etc/collectd/collectd.conf 

CMD /usr/sbin/collectd -f -C /etc/collectd/collectd.conf 
