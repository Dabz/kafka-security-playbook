#!/usr/bin/env bash

DEFAULT_PASSWORD=${1:-confluent}

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

mkdir $CA_ROOT_DIR/ca;
cd $CA_ROOT_DIR/ca;

mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial


openssl genrsa -aes256 -passout pass:$DEFAULT_PASSWORD -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

cp ../configs/ca.config openssl.cnf

openssl req -config openssl.cnf \
     -key private/ca.key.pem \
     -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -passin pass:$DEFAULT_PASSWORD -passout pass:$DEFAULT_PASSWORD \
     -out certs/ca.cert.pem

 chmod 444 certs/ca.cert.pem

## Verify the CA certificate
openssl x509 -noout -text -in certs/ca.cert.pem

cd ..
