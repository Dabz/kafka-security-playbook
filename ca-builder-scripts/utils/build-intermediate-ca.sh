#!/usr/bin/env bash

DEFAULT_PASSWORD=${1:-confluent}

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

cd $CA_ROOT_DIR/ca;

mkdir intermediate
cd intermediate

mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

cp ../../configs/intermediate-ca.config openssl.cnf

openssl genrsa -aes256 -passout pass:$DEFAULT_PASSWORD -out private/intermediate.key.pem 4096
chmod 400 private/intermediate.key.pem

openssl req -config openssl.cnf -new -sha256 \
     -passin pass:$DEFAULT_PASSWORD -passout pass:$DEFAULT_PASSWORD \
     -key private/intermediate.key.pem \
     -out csr/intermediate.csr.pem
cd ..

openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
          -days 3650 -notext -md sha256 \
          -in intermediate/csr/intermediate.csr.pem \
          -passin pass:$DEFAULT_PASSWORD \
          -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem

## verification

openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem
openssl verify -CAfile certs/ca.cert.pem  intermediate/certs/intermediate.cert.pem

## create the CA chain
cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem

cd ..
