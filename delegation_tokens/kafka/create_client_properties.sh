#!/bin/bash

set -e
set -u

RESPONSE=$(kafka-delegation-tokens \
        --bootstrap-server kafka.confluent.local:9093 \
        --create \
        --command-config /etc/kafka/consumer.properties \
        --max-life-time-period -1 | tail -1)

TOKENID=$(echo $RESPONSE | cut -d " " -f1)
HMAC=$(echo $RESPONSE | cut -d " " -f2)

echo "Received token id: $TOKENID"
echo "Received message authentication code: $HMAC"

echo 'sasl.mechanism=SCRAM-SHA-256
# Configure SASL_SSL if SSL encryption is enabled, otherwise configure SASL_PLAINTEXT
security.protocol=SASL_SSL
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
  username="'$TOKENID'" \
  password="'$HMAC'" \
  tokenauth="true";
ssl.truststore.location=/var/lib/secret/truststore.jks
ssl.truststore.password=test1234
ssl.keystore.location=/var/lib/secret/client.keystore.jks
ssl.keystore.password=test1234' > /tmp/delegation_token_client.properties

