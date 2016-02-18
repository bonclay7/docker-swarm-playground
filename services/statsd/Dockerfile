FROM node:latest

RUN apt-get -y update && apt-get install -y git

RUN git clone https://github.com/etsy/statsd.git /statsd

WORKDIR /statsd

ADD config.js ./conf/config.js

EXPOSE 8125:8125/udp

CMD node stats.js conf/config.js
