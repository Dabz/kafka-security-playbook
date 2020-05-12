#!/usr/bin/env bash

echo "Create topic foo with User:kafka"
echo "NOTE: this topic creation will be ignored because uses a user inside the ignore list."
echo
docker exec kafka kafka-topics --bootstrap-server kafka:9092 \
              --command-config /etc/kafka/kafka-user.properties \
              --create --topic foo --replication-factor 1 --partitions 1
sleep 1
echo "Create topic bar with User:producer"
echo "NOTE: This action will be noted in the audit log."
echo
docker exec kafka kafka-topics --bootstrap-server kafka:9092 \
              --command-config /etc/kafka/producer-user.properties \
              --create --topic bar --replication-factor 1 --partitions 1

## Add extra ACLs need to handle the topic bar
docker exec kafka kafka-acls --bootstrap-server kafka:9092 \
        --command-config /etc/kafka/kafka-user.properties \
        --add --allow-principal User:producer --operation AlterConfigs \
        --topic "bar"

docker exec kafka kafka-acls --bootstrap-server kafka:9092 \
        --command-config /etc/kafka/kafka-user.properties \
        --add --allow-principal User:producer --operation Delete \
        --topic "bar"

sleep 1

echo "Change of a configuration"
echo "NOTE: This action will be noted in the audit log."
echo
docker exec kafka kafka-configs --bootstrap-server kafka:9092 \
            --topic bar --add-config retention.ms=2592000001 \
            --alter --command-config /etc/kafka/producer-user.properties
