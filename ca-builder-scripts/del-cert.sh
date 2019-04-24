#!/usr/bin/env bash

NAME=$1

echo "Deleting CERT $NAME"

rm "ca/intermediate/private/$NAME.key.pem"
rm "ca/intermediate/certs/$NAME.cert.pem"
rm "ca/intermediate/csr/$NAME.csr.pem"
