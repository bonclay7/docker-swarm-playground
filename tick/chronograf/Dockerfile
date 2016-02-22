FROM debian:latest

RUN apt-get update && apt-get install -y wget curl telnet

WORKDIR /tmp

RUN wget https://s3.amazonaws.com/get.influxdb.org/chronograf/chronograf_0.10.0_amd64.deb \
  && dpkg -i chronograf_0.10.0_amd64.deb

ENV CHRONOGRAF_BIND 0.0.0.0:10000

EXPOSE 10000

CMD /opt/chronograf/./chronograf
