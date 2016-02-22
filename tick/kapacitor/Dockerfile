FROM debian:latest

RUN apt-get update && apt-get install -y wget curl telnet

WORKDIR /tmp

RUN wget https://s3.amazonaws.com/kapacitor/kapacitor_0.10.1-1_amd64.deb \
  && dpkg -i kapacitor_0.10.1-1_amd64.deb

ADD ./kapacitor.conf /etc/kapacitor/kapacitor.conf

EXPOSE 9092

CMD /usr/bin/kapacitord -config /etc/kapacitor/kapacitor.conf
