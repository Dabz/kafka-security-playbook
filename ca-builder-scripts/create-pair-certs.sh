#!/usr/bin/env bash

#HOSTNAME="www.example.com"
#EXTENSION="server_cert" #usr_cert for client auth, server_cert for for backend

#HOSTNAME="my.kafka.consumer"
#EXTENSION="usr_cert"

HOSTNAME=$1
EXTENSION=$2

echo "Building a part of certificates for $HOSTNAME using $EXTENSION"

cd ca;

# create a private key
openssl genrsa -aes256 -out intermediate/private/$HOSTNAME.key.pem 2048
chmod 400 intermediate/private/$HOSTNAME.key.pem

# create a csr
openssl req -config intermediate/openssl.cnf \
      -key intermediate/private/$HOSTNAME.key.pem \
      -new -sha256 -out intermediate/csr/$HOSTNAME.csr.pem

# create the cert
openssl ca -config intermediate/openssl.cnf -extensions $EXTENSION -days 375 -notext -md sha256 \
           -in intermediate/csr/$HOSTNAME.csr.pem \
           -out intermediate/certs/$HOSTNAME.cert.pem

chmod 444 intermediate/certs/$HOSTNAME.cert.pem

# verify the cert
openssl x509 -noout -text -in intermediate/certs/$HOSTNAME.cert.pem

# verify the chain trust
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem intermediate/certs/$HOSTNAME.cert.pem

cd ..;
