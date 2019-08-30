#!/usr/bin/env bash

DEFAULT_PASSWORD=${1:-confluent}

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

source $CA_ROOT_DIR/utils/functions.sh

mkdir $CA_ROOT_DIR/ca;

setup_ca_dir_structure "$CA_ROOT_DIR/ca"

cp $CA_ROOT_DIR/configs/ca.config $CA_ROOT_DIR/ca/openssl.cnf

(cd $CA_ROOT_DIR/ca; generate_ca_keys_and_certs )

## Verify the CA certificate
openssl x509 -noout -text -in $CA_ROOT_DIR/ca/certs/ca.cert.pem
