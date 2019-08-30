#!/usr/bin/env bash


DEFAULT_PASSWORD=${1:-confluent}

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

source $CA_ROOT_DIR/utils/functions.sh

(cd $CA_ROOT_DIR/ca; create_certificate_revokation_list )
