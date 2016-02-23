FROM debian:latest

ARG TELEGRAF_VERSION=0.10.3-1

RUN apt-get update && apt-get install -y wget lsof

WORKDIR /tmp

RUN wget http://get.influxdb.org/telegraf/telegraf_${TELEGRAF_VERSION}_amd64.deb \
  && dpkg -i telegraf_${TELEGRAF_VERSION}_amd64.deb

ADD ./telegraf.conf /etc/telegraf/telegraf.conf

CMD /usr/bin/telegraf -config /etc/telegraf/telegraf.conf