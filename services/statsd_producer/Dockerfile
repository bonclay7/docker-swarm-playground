FROM ubuntu:latest

RUN apt-get update -y && apt-get install -y netcat

WORKDIR /root

ADD send_dummy_values.sh .

CMD ./send_dummy_values.sh
