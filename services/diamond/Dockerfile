FROM python:2-onbuild

ENV http_proxy ""
ENV https_proxy ""
ENV ftp_proxy ""

RUN mkdir -p /etc/diamond/

RUN mkdir -p /var/log/diamond/

RUN apt-get update -y && apt-get install -y tcpdump telnet curl

WORKDIR /etc/diamond/

ADD diamond.conf .

ADD run_diamond.sh .

ADD influxdbHandler.py /usr/local/lib/python2.7/site-packages/diamond/handler/

CMD ./run_diamond.sh
