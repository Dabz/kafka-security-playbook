#!/usr/bin/env bash

docker exec kafka kafka-topics --bootstrap-server kafka:9092 --command-config /etc/kafka/kafka-user.properties --describe
