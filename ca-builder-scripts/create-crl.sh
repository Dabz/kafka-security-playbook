#!/usr/bin/env bash

cd ca;

openssl ca -config intermediate/openssl.cnf -gencrl -out intermediate/crl/intermediate.crl.pem

cd ..
