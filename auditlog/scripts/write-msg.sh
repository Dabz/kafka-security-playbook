#!/usr/bin/env bash

PWD=`pwd`
topic=$1
network="auditlog_default"

USERNAME=producer
PASSWORD=producerpass

echo "Write messages to topic $1"

docker run --network $network \
    --volume $PWD/data/my_msgs.txt:/data/my_msgs.txt \
           confluentinc/cp-kafkacat \
           kafkacat -b kafka:9092 \
                    -t $topic \
                    -X security.protocol=SASL_PLAINTEXT -X sasl.mechanisms=SCRAM-SHA-256 -X sasl.username=$USERNAME -X sasl.password=$PASSWORD \
                    -P -l /data/my_msgs.txt
