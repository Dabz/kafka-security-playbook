#!/usr/bin/env bash

verify_ssl_client_auth () {

  openssl pkcs12 -in connect/secrets/$1.p12 -out connect/secrets/ca.pem -cacerts -nokeys -passin pass:confluent -passout pass:confluent
  openssl pkcs12 -in connect/secrets/$1.p12 -out connect/secrets/client.pem -clcerts -nokeys -passin pass:confluent -passout pass:confluent
  openssl pkcs12 -in connect/secrets/$1.p12 -out connect/secrets/key.pem -nocerts -passin pass:confluent -passout pass:confluent

  curl --insecure --key connect/secrets/key.pem --cacert connect/secrets/ca.pem --cert connect/secrets/client.pem:confluent https://localhost:18083
}

echo "Check SSL client auth with an unknown certificate"
verify_ssl_client_auth "certificate"

echo "Check SSL client auth with a valid client"
verify_ssl_client_auth "rest-client"
