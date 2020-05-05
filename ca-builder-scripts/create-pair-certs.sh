#!/usr/bin/env bash

#HOSTNAME="www.example.com"
#EXTENSION="server_cert" #usr_cert for client auth, server_cert for for backend

#HOSTNAME="my.kafka.consumer"
#EXTENSION="usr_cert"

HOSTNAME=$1
MACHINE=$2
EXTENSION=$3
DEFAULT_PASSWORD=${4:-confluent}

echo "Building a part of certificates for $HOSTNAME using $EXTENSION"

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

ITERMEDIATE_CA_DIR=$CA_ROOT_DIR/ca/intermediate


source $CA_ROOT_DIR/utils/functions.sh

(cd $CA_ROOT_DIR; refresh_openssl_file "$CA_ROOT_DIR" "$ITERMEDIATE_CA_DIR" )
(cd $CA_ROOT_DIR/ca; generate_final_certificate "$MACHINE" )
