#!/bin/bash 

echo 'some sample messages
sent via sasl outh bearer authentication
with custom token generation and validation. 
' | kafka-console-producer --broker-list kafka:9093 --topic test --producer.config /etc/kafka/client.properties
timeout 5 kafka-console-consumer --bootstrap-server kafka:9093 --topic test --from-beginning --consumer.config /etc/kafka/client.properties
