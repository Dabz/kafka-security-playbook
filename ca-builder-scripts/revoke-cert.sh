#!/usr/bin/env bash

CERT=$1
DEFAULT_PASSWORD=${2:-confluent}

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

cd $CA_ROOT_DIR/ca;

openssl ca -config intermediate/openssl.cnf -passin pass:$DEFAULT_PASSWORD -revoke "intermediate/certs/$1.cert.pem"

cd ..;
