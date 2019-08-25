#!/usr/bin/env bash

generate_ca_keys_and_certs () {

openssl genrsa -aes256 -passout pass:$DEFAULT_PASSWORD -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

openssl req -config openssl.cnf \
     -key private/ca.key.pem \
     -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -passin pass:$DEFAULT_PASSWORD -passout pass:$DEFAULT_PASSWORD \
     -out certs/ca.cert.pem

 chmod 444 certs/ca.cert.pem
}

setup_ca_dir_structure() {
  mkdir -p $1/certs $1/crl $1/newcerts $1/private
  chmod 700 $1/private
  touch $1/index.txt
  echo 1000 > $1/serial
}

setup_intermediate_ca_dir_structure() {
  setup_ca_dir_structure $1
  mkdir -p $1/csr
  echo 1000 > $1/crlnumber
}


generate_intermediate_keys_and_certs () {
  openssl genrsa -aes256 -passout pass:$DEFAULT_PASSWORD -out private/intermediate.key.pem 4096
  chmod 400 private/intermediate.key.pem

  openssl req -config openssl.cnf -new -sha256 \
       -passin pass:$DEFAULT_PASSWORD -passout pass:$DEFAULT_PASSWORD \
       -key private/intermediate.key.pem \
       -out csr/intermediate.csr.pem
}

sign_intermediate_cert_authority () {
  # signature
  openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
            -days 3650 -notext -md sha256 \
            -in intermediate/csr/intermediate.csr.pem \
            -passin pass:$DEFAULT_PASSWORD \
            -out intermediate/certs/intermediate.cert.pem
  chmod 444 intermediate/certs/intermediate.cert.pem
}

verify_generate_intermediate_ca () {
  # verification
  openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem
  openssl verify -CAfile certs/ca.cert.pem  intermediate/certs/intermediate.cert.pem
}

create_ca_chain () {
  # create the CA chain
  cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
  chmod 444 intermediate/certs/ca-chain.cert.pem
}

generate_final_certificate () {
  # create a private key
  openssl genrsa -aes256 -passout pass:$DEFAULT_PASSWORD  -out intermediate/private/$HOSTNAME.key.pem 2048
  chmod 400 intermediate/private/$HOSTNAME.key.pem

  # create a csr
  openssl req -config intermediate/openssl.cnf \
        -passin pass:confluent -passout pass:$DEFAULT_PASSWORD \
        -key intermediate/private/$HOSTNAME.key.pem \
        -new -sha256 -out intermediate/csr/$HOSTNAME.csr.pem

  # create the cert
  openssl ca -config intermediate/openssl.cnf -extensions $EXTENSION -days 375 -notext -md sha256 \
             -in intermediate/csr/$HOSTNAME.csr.pem \
             -passin pass:$DEFAULT_PASSWORD \
             -out intermediate/certs/$HOSTNAME.cert.pem

  chmod 444 intermediate/certs/$HOSTNAME.cert.pem

  # verify the cert
  openssl x509 -noout -text -in intermediate/certs/$HOSTNAME.cert.pem

  # verify the chain trust
  openssl verify -CAfile intermediate/certs/ca-chain.cert.pem intermediate/certs/$HOSTNAME.cert.pem
}

create_certificate_revokation_list () {
  openssl ca -config intermediate/openssl.cnf -gencrl \
            -passin pass:$DEFAULT_PASSWORD \
            -out intermediate/crl/intermediate.crl.pem
}
