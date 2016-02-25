#!/usr/bin/env python
import threading, logging, time

from kafka import KafkaConsumer, KafkaProducer


class Producer(threading.Thread):
    daemon = True

    def run(self):
        print "producer"
        producer = KafkaProducer(bootstrap_servers='192.168.99.103:9092')
        print "producer... ok"

        while True:
            producer.send('my-topic', b"test")
            producer.send('my-topic', b"\xc2Hola, mundo!")
            time.sleep(1)


class Consumer(threading.Thread):
    daemon = True

    def run(self):
        print "consummer"
        consumer = KafkaConsumer(bootstrap_servers='192.168.99.103:9092',
                                 auto_offset_reset='earliest')
        print "consummer ... ok"
        consumer.subscribe(['my-topic'])

        for message in consumer:
            print (message)


def main():
    threads = [
        Producer(),
        Consumer()
    ]

    for t in threads:
        t.start()

    time.sleep(10)

if __name__ == "__main__":
    logging.basicConfig(
        format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
        level=logging.INFO
        )
    main()
