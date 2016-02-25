FROM debian:latest

RUN apt-get update 
RUN apt-get install -y python python-pip
RUN apt-get install -y libsnappy-dev python-snappy
RUN pip install kafka-python

WORKDIR /tmp
COPY sample.py /tmp
CMD /tmp/sample.py