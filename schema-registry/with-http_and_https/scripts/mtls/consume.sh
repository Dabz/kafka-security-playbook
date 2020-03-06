#!/usr/bin/env bash

export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.trustStore=/etc/kafka/secrets/schema-registry.truststore \
           -Djavax.net.ssl.trustStorePassword=confluent \
           -Djavax.net.ssl.keyStore=/etc/kafka/secrets/schema-registry.keystore \
           -Djavax.net.ssl.keyStorePassword=confluent \
           -javaagent:/plugins/verification.jar"

kafka-avro-console-consumer --topic topic-tls  --from-beginning \
  --bootstrap-server kafka:29092 \
  --property schema.registry.url=https://schema-registry:8082
