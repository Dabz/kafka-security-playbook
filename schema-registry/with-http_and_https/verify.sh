#!/usr/bin/env bash

verify_ok_ssl_client_auth () {
  cp -f ../../ca-builder-scripts/ca/intermediate/private/$1.key.pem schema-registry/secrets/$1.key.pem
  cp -f ../../ca-builder-scripts/ca/intermediate/certs/ca-chain.cert.pem schema-registry/secrets/ca-chain.cert.pem
  cp -f ../../ca-builder-scripts/ca/intermediate/certs/$1.cert.pem schema-registry/secrets/$1.cert.pem
  curl --key schema-registry/secrets/$1.key.pem --cacert schema-registry/secrets/ca-chain.cert.pem --cert schema-registry/secrets/$1.cert.pem:confluent https://localhost:8099
}

verify_ko_ssl_client_auth() {
  mkdir schema-registry/certs
  openssl req -new -nodes -x509 -days 3650 -newkey rsa:2048 -keyout schema-registry/certs/ca.key -out schema-registry/certs/ca.crt -config schema-registry/config/ca.cnf
  cat schema-registry/certs/ca.crt schema-registry/certs/ca.key > schema-registry/certs/ca.pem

  openssl req -new -newkey rsa:2048 -keyout schema-registry/certs/client.key -out schema-registry/certs/client.csr -config schema-registry/config/client.cnf -nodes
  openssl x509 -req -days 3650 -in schema-registry/certs/client.csr -CA schema-registry/certs/ca.crt -CAkey schema-registry/certs/ca.key -CAcreateserial -out schema-registry/certs/client.crt -extfile schema-registry/config/client.cnf -extensions v3_req
  openssl pkcs12 -export -in schema-registry/certs/client.crt -inkey schema-registry/certs/client.key -chain -CAfile schema-registry/certs/ca.pem -name "schema-registry" -out schema-registry/certs/client.p12 -password pass:confluent

  cp schema-registry/certs/client.p12 schema-registry/secrets/client.p12
  rm -rf schema-registry/certs

  openssl pkcs12 -in schema-registry/secrets/client.p12 -out schema-registry/secrets/client-ca.pem -cacerts -nokeys -passin pass:confluent -passout pass:confluent
  openssl pkcs12 -in schema-registry/secrets/client.p12 -out schema-registry/secrets/client-client.pem -clcerts -nokeys -passin pass:confluent -passout pass:confluent
  openssl pkcs12 -in schema-registry/secrets/client.p12 -out schema-registry/secrets/client-key.pem -nocerts -passin pass:confluent -passout pass:confluent

  curl --insecure --key schema-registry/secrets/client-key.pem --cacert schema-registry/secrets/client-ca.pem  --cert schema-registry/secrets/client-client.pem:confluent https://localhost:8099
}


echo "Check SSL client auth with an unknown certificate"
verify_ko_ssl_client_auth

echo ""
echo ""

echo "Check SSL client auth with a valid client"
verify_ok_ssl_client_auth "schema-registry"
