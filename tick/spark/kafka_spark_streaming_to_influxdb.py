"""
 bin/spark-submit --packages org.apache.spark:spark-streaming-kafka_2.10:1.6.0 \
     basic_kafka_streaming.py zookeeper:2181 kafka_to_influxdb_via_spark
"""
from __future__ import print_function

import time
import sys
import urllib2 
import httplib, urllib

from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils
from pyspark.storagelevel import StorageLevel

def latin_decoder(s):
    return s and s.decode('latin-1')

def dump_to_influxdb(rdd):
    lines = rdd.values().collect()
    print("Got {} lines to be sent to influxdb".format(len(lines)))
    data = "\n".join(lines)

    try:
        url = 'http://influxdb:8086/write?db=kafka_to_influxdb_via_spark'
        headers = {'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': len(data)}
        request = urllib2.Request(url, data=data, headers=headers)
        urllib2.urlopen(request)
    except:
        print("response ko with")
        print(data)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: kafka_spark_streaming_to_influxdb.py <zk> <topic>", file=sys.stderr)
        exit(-1)

    sc = SparkContext(appName="KafkaSparkStreamingToInfluxDb")
    ssc = StreamingContext(sc, 2)

    zkQuorum, topic = sys.argv[1:]
    directKafkaStream = KafkaUtils.createStream(ssc, zkQuorum, "spark-streaming-kafka-to-influxdb", topics={topic: 1}, kafkaParams={'auto.offset.reset': 'smallest'}, storageLevel=StorageLevel.MEMORY_AND_DISK, keyDecoder=latin_decoder, valueDecoder=latin_decoder)
    directKafkaStream.foreachRDD(dump_to_influxdb)

    ssc.start()
    ssc.awaitTermination()