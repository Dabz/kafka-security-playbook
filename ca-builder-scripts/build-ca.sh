#!/usr/bin/env bash

mkdir ca;
cd ca;

mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial


openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

cp ../configs/ca.config openssl.cnf

openssl req -config openssl.cnf \
     -key private/ca.key.pem \
     -new -x509 -days 7300 -sha256 -extensions v3_ca \
     -out certs/ca.cert.pem

 chmod 444 certs/ca.cert.pem

## Verify the CA certificate
openssl x509 -noout -text -in certs/ca.cert.pem

cd ..
