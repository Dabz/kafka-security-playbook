#!/bin/bash

set -u
set -e

validity=1
keystore_pass=secret
key_pass=secret
distinguished_name=kafka.confluent.local
hostname=kafka.confluent.local

rm -rf certs
mkdir certs
pushd certs

# Generate server certificate
keytool -keystore kafka.server.keystore.jks \
        -alias localhost \
        -validity ${validity} \
        -genkey \
        -storepass ${keystore_pass} \
        -key-pass ${key_pass} \
        -dname "CN=kafka.confluent.local, OU=CS, O=Confluent, L=Palo Alto, S=CA, C=US" \
        -ext SAN=DNS:${hostname}

# keytool -list -v -keystore kafka.server.keystore.jks -storepass ${keystore_pass}

# Generate certificate auithority
openssl req -new -nodes -x509 -newkey rsa:2048 -keyout ca-key -out ca-cert -days ${validity} -config ../ca.cnf

echo "Importing certificate authority into client truststore."
keytool -keystore kafka.client.truststore.jks \
        -alias CARoot \
        -import \
        -file ca-cert \
        -store-pass ${keystore_pass} \
        -no-prompt

echo "Importing certificate authority into server truststore."
keytool -keystore kafka.server.truststore.jks \
        -alias CARoot \
        -import \
        -file ca-cert \
        -store-pass ${keystore_pass} \
        -no-prompt

echo "Exporting server certificate such that it can be signed."
keytool -keystore kafka.server.keystore.jks \
        -alias localhost \
        -certreq \
        -file cert-file \
        -store-pass ${keystore_pass} 

echo "Signing exported server certificate."
openssl x509 -req \
        -CA ca-cert \
        -CAkey ca-key \
        -in cert-file \
        -out cert-signed \
        -days ${validity} \
        -CAcreateserial \
        -passin pass:{ca-password}

echo "Importing certificate authority into keystore."
keytool -keystore kafka.server.keystore.jks \
        -alias CARoot \
        -import -file ca-cert \
        -store-pass ${keystore_pass} \
        -no-prompt
    
echo "Importing signed certificate into server keystore."
keytool -keystore kafka.server.keystore.jks \
        -alias localhost \
        -import \
        -file cert-signed \
        -store-pass ${keystore_pass} \
        -no-prompt
         
echo "Moving client truststore and kafka truststore and kafka keystore to Kafka docker directory"
popd
mv certs/kafka.server.truststore.jks kafka
mv certs/kafka.server.keystore.jks kafka
mv certs/kafka.client.truststore.jks kafka

