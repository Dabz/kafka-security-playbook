#!/usr/bin/env bash

DEFAULT_PASSWORD=${2:-confluent}

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

CA_CERT="$CA_ROOT_DIR/ca/certs/ca.cert.pem"
CA_KEY="$CA_ROOT_DIR/ca/private/ca.key.pem"

INT_CA_CERT="$CA_ROOT_DIR/ca/intermediate/certs/intermediate.cert.pem"
INT_CA_KEY="$CA_ROOT_DIR/ca/intermediate/private/intermediate.key.pem"

function build_store {
  cert_name=$1
  store_type=$2

  CERT_PATH="$CA_ROOT_DIR/ca/intermediate/certs/$cert_name.cert.pem"
  KEY_PATH="$CA_ROOT_DIR/ca/intermediate/private/$cert_name.key.pem"
  openssl pkcs12 -export -in $CERT_PATH -inkey $KEY_PATH -passin pass:$DEFAULT_PASSWORD -passout pass:$DEFAULT_PASSWORD -name $cert_name -out tmp-certs/$cert_name.p12
  sleep 1
  ## build keystore and truststores
  keytool -noprompt -importkeystore -deststorepass $DEFAULT_PASSWORD -destkeystore stores/$store_type.keystore -srckeystore tmp-certs/$cert_name.p12 -srcstorepass $DEFAULT_PASSWORD -storepass $DEFAULT_PASSWORD -keypass $DEFAULT_PASSWORD -srcstoretype PKCS12 -deststoretype pkcs12

  openssl pkcs12 -export -in $CA_CERT -inkey $CA_KEY -passin pass:$DEFAULT_PASSWORD -passout pass:$DEFAULT_PASSWORD -name 'ca' -out tmp-certs/ca.p12
  sleep 1
  openssl pkcs12 -export -in $INT_CA_CERT -inkey $INT_CA_KEY -passin pass:$DEFAULT_PASSWORD -passout pass:$DEFAULT_PASSWORD -name 'intermediate-ca' -out tmp-certs/inter-ca.p12
  sleep 1

  keytool -noprompt -importkeystore -deststorepass $DEFAULT_PASSWORD -destkeystore stores/$store_type.truststore -srckeystore tmp-certs/ca.p12 -srcstorepass $DEFAULT_PASSWORD -srcstoretype PKCS12 -storepass $DEFAULT_PASSWORD -keypass $DEFAULT_PASSWORD -deststoretype pkcs12
  sleep 1
  keytool -noprompt -importkeystore -deststorepass $DEFAULT_PASSWORD -destkeystore stores/$store_type.truststore -srckeystore tmp-certs/inter-ca.p12 -srcstorepass $DEFAULT_PASSWORD -srcstoretype PKCS12 -storepass $DEFAULT_PASSWORD -keypass $DEFAULT_PASSWORD -deststoretype pkcs12
}

## buildind stores for the brokers

mkdir -p stores tmp-certs

CONFIG_FILE=$1
while read data; do
  fields=($(echo $data | tr "," "\n"))
  echo "Building a store for ${fields[0]} and ${fields[1]}"
  build_store "${fields[0]}" "${fields[1]}"
done <$CONFIG_FILE

rm -rf temp-certs
