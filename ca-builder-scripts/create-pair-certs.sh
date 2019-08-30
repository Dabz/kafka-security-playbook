#!/usr/bin/env bash

#HOSTNAME="www.example.com"
#EXTENSION="server_cert" #usr_cert for client auth, server_cert for for backend

#HOSTNAME="my.kafka.consumer"
#EXTENSION="usr_cert"

HOSTNAME=$1
EXTENSION=$2
DEFAULT_PASSWORD=${3:-confluent}

echo "Building a part of certificates for $HOSTNAME using $EXTENSION"

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

source $CA_ROOT_DIR/utils/functions.sh

(cd $CA_ROOT_DIR/ca; generate_final_certificate )
