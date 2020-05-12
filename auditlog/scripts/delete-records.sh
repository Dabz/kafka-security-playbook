#!/usr/bin/env bash

docker exec kafka  kafka-delete-records --bootstrap-server kafka:9092 \
              --command-config /etc/kafka/producer-user.properties \
              --offset-json-file /tmp/config/delete-records.json
