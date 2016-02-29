FROM java:7

RUN apt-get update && apt-get install -y curl python python-pip tar

ARG SPARK_VERSION=1.6.0
ENV SPARK_VERSION ${SPARK_VERSION}

WORKDIR /opt

RUN curl http://apache.mirrors.ovh.net/ftp.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz | tar xvz

WORKDIR /opt/spark-${SPARK_VERSION}-bin-hadoop2.6

ADD basic_kafka_streaming.py .

CMD bin/spark-submit --packages org.apache.spark:spark-streaming-kafka_2.10:${SPARK_VERSION} \
    basic_kafka_streaming.py zookeeper:2181 metrics
