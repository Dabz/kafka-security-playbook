#!/usr/bin/env bash

NAME=$1

if [ -z "${CA_ROOT_DIR+x}" ];
then
CA_ROOT_DIR='.'
fi

echo "Deleting CERT $NAME"

rm "$CA_ROOT_DIR/ca/intermediate/private/$NAME.key.pem"
rm "$CA_ROOT_DIR/ca/intermediate/certs/$NAME.cert.pem"
rm "$CA_ROOT_DIR/ca/intermediate/csr/$NAME.csr.pem"
