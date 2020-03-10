#!/usr/bin/env bash

verify_ok_ssl_client_auth () {
  cp -f ../ca-builder-scripts/ca/intermediate/private/$1.key.pem connect/secrets/$1.key.pem
  cp -f ../ca-builder-scripts/ca/intermediate/certs/ca-chain.cert.pem connect/secrets/ca-chain.cert.pem
  cp -f ../ca-builder-scripts/ca/intermediate/certs/$1.cert.pem connect/secrets/$1.cert.pem
  curl --key connect/secrets/$1.key.pem --cacert connect/secrets/ca-chain.cert.pem --cert connect/secrets/$1.cert.pem:confluent https://localhost:18083
}

verify_ko_ssl_client_auth() {
  mkdir connect/certs
  openssl req -new -nodes -x509 -days 3650 -newkey rsa:2048 -keyout connect/certs/ca.key -out connect/certs/ca.crt -config connect/config/ca.cnf
  cat connect/certs/ca.crt connect/certs/ca.key > connect/certs/ca.pem

  openssl req -new -newkey rsa:2048 -keyout connect/certs/client.key -out connect/certs/client.csr -config connect/config/client.cnf -nodes
  openssl x509 -req -days 3650 -in connect/certs/client.csr -CA connect/certs/ca.crt -CAkey connect/certs/ca.key -CAcreateserial -out connect/certs/client.crt -extfile connect/config/client.cnf -extensions v3_req
  openssl pkcs12 -export -in connect/certs/client.crt -inkey connect/certs/client.key -chain -CAfile connect/certs/ca.pem -name "connect" -out connect/certs/client.p12 -password pass:confluent

  cp connect/certs/client.p12 connect/secrets/client.p12
  rm -rf connect/certs

  openssl pkcs12 -in connect/secrets/client.p12 -out connect/secrets/client-ca.pem -cacerts -nokeys -passin pass:confluent -passout pass:confluent
  openssl pkcs12 -in connect/secrets/client.p12 -out connect/secrets/client-client.pem -clcerts -nokeys -passin pass:confluent -passout pass:confluent
  openssl pkcs12 -in connect/secrets/client.p12 -out connect/secrets/client-key.pem -nocerts -passin pass:confluent -passout pass:confluent

  curl --insecure --key connect/secrets/client-key.pem --cacert connect/secrets/client-ca.pem  --cert connect/secrets/client-client.pem:confluent https://localhost:18083
}


echo "Check SSL client auth with an unknown certificate"
verify_ko_ssl_client_auth

echo ""
echo ""

echo "Check SSL client auth with a valid client"
verify_ok_ssl_client_auth "connect"
