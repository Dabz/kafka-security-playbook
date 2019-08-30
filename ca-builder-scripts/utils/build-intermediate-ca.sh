#!/usr/bin/env bash

DEFAULT_PASSWORD=${1:-confluent}

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi
ITERMEDIATE_CA_DIR=$CA_ROOT_DIR/ca/intermediate

source $CA_ROOT_DIR/utils/functions.sh

mkdir -p $ITERMEDIATE_CA_DIR

setup_intermediate_ca_dir_structure $ITERMEDIATE_CA_DIR

cp $CA_ROOT_DIR/configs/intermediate-ca.config $ITERMEDIATE_CA_DIR/openssl.cnf

(cd $ITERMEDIATE_CA_DIR; generate_intermediate_keys_and_certs)

(cd $CA_ROOT_DIR/ca; sign_intermediate_cert_authority; verify_generate_intermediate_ca)
(cd $CA_ROOT_DIR/ca; create_ca_chain)
