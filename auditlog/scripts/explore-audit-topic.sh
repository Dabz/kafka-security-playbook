#!/usr/bin/env bash

TOPIC="confluent-audit-log-events"
docker-compose exec kafka kafka-console-consumer --bootstrap-server kafka:9092 \
               --consumer.config /etc/kafka/kafka-user.properties \
               --topic $TOPIC --from-beginning
