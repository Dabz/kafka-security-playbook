#!/usr/bin/env bash

CERT=$1
DEFAULT_PASSWORD=${2:-confluent}

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

source $CA_ROOT_DIR/utils/functions.sh

(cd $CA_ROOT_DIR/ca; revoke_cert $CERT )
