#!/usr/bin/env bash

kafka-avro-console-producer --broker-list kafka:29092 --topic topic \
  --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}' \
  --property schema.registry.url=http://schema-registry:8081 < $1
