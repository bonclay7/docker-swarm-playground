FROM debian:latest

ARG CHRONOGRAPH_VERSION=0.10.0

RUN apt-get update && apt-get install -y wget

WORKDIR /tmp

RUN wget https://s3.amazonaws.com/get.influxdb.org/chronograf/chronograf_${CHRONOGRAPH_VERSION}_amd64.deb \
  && dpkg -i chronograf_${CHRONOGRAPH_VERSION}_amd64.deb

ENV CHRONOGRAF_BIND 0.0.0.0:10000

EXPOSE 10000

CMD /opt/chronograf/./chronograf
