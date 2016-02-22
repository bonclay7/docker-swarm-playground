FROM debian:latest

RUN apt-get update && apt-get install -y wget curl telnet lsof

WORKDIR /tmp

RUN wget http://get.influxdb.org/telegraf/telegraf_0.10.3-1_amd64.deb \
  && dpkg -i telegraf_0.10.3-1_amd64.deb

ADD ./telegraf.conf /etc/telegraf/telegraf.conf

CMD /usr/bin/telegraf -config /etc/telegraf/telegraf.conf
