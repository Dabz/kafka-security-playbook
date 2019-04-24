#!/usr/bin/env bash

CERT=$1

cd ca;

openssl ca -config intermediate/openssl.cnf -revoke "intermediate/certs/$1.cert.pem"

cd ..;
