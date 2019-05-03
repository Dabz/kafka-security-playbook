#!/usr/bin/env bash

CERT=$1

cd ca;

openssl ca -config intermediate/openssl.cnf -passin pass:confluent -revoke "intermediate/certs/$1.cert.pem"

cd ..;
