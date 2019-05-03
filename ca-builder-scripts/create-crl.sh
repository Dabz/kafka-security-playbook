#!/usr/bin/env bash

cd ca;

openssl ca -config intermediate/openssl.cnf -gencrl \
          -passin pass:confluent \
          -out intermediate/crl/intermediate.crl.pem

cd ..
