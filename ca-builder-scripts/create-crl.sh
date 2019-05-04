#!/usr/bin/env bash

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

cd $CA_ROOT_DIR/ca;

openssl ca -config intermediate/openssl.cnf -gencrl \
          -passin pass:confluent \
          -out intermediate/crl/intermediate.crl.pem

cd ..
