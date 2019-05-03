#!/usr/bin/env bash

CERT=$1
DEFAULT_PASSWORD=${2:-confluent}

cd ca;

openssl ca -config intermediate/openssl.cnf -passin pass:$DEFAULT_PASSWORD -revoke "intermediate/certs/$1.cert.pem"

cd ..;
