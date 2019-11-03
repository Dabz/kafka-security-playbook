#!/usr/bin/env bash

openssl pkcs12 -in connect/secrets/rest-client.p12 -out connect/secrets/ca.pem -cacerts -nokeys -passin pass:confluent -passout pass:confluent
openssl pkcs12 -in connect/secrets/rest-client.p12 -out connect/secrets/client.pem -clcerts -nokeys -passin pass:confluent -passout pass:confluent
openssl pkcs12 -in connect/secrets/rest-client.p12 -out connect/secrets/key.pem -nocerts -passin pass:confluent -passout pass:confluent

curl --insecure --key connect/secrets/key.pem --cacert connect/secrets/ca.pem --cert connect/secrets/client.pem:confluent https://localhost:18083
