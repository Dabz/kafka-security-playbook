#!/usr/bin/env bash

export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.trustStore=/etc/kafka/secrets/avocado.truststore \
           -Djavax.net.ssl.trustStorePassword=confluent \
           -Djavax.net.ssl.keyStore=/etc/kafka/secrets/avocado.keystore \
           -Djavax.net.ssl.keyStorePassword=confluent \
           -javaagent:/plugins/verification.jar"


kafka-avro-console-producer --broker-list kafka:29092 --topic topic-tls \
  --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}' \
  --property schema.registry.url=https://schema-registry:8082 < $1
