FROM debian:latest

ARG KAPACITOR_VERSION=0.10.1-1

RUN apt-get update && apt-get install -y wget

WORKDIR /tmp

RUN wget https://s3.amazonaws.com/kapacitor/kapacitor_${KAPACITOR_VERSION}_amd64.deb \
  && dpkg -i kapacitor_${KAPACITOR_VERSION}_amd64.deb

ADD ./kapacitor.conf /etc/kapacitor/kapacitor.conf
ADD ./tasks /etc/kapacitor/tasks

EXPOSE 9092

CMD /usr/bin/kapacitord -config /etc/kapacitor/kapacitor.conf
