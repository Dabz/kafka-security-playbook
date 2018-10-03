# TLS Cheat Sheet

## Introduction 

This cheat sheet contains common commands regarding TLS certificate generation and TLS troubleshooting. If you are looking for a script to generate keystore , certificate authority and certificates, I recommend you to check out [confluent kafka-generate-ssl.sh script](https://github.com/confluentinc/confluent-platform-security-tools/blob/master/kafka-generate-ssl.sh)

##  Generating self-signed certificates or a new Certificate Authority

```bash
openssl req -new -nodes -x509 -days 3650 -newkey rsa:2048 -keyout sever.key -out certs/server.crt -config $CONFIG_PATH
```


##  Generating certificate signing request

```bash
openssl req -new -newkey rsa:2048 -keyout server.key -out server.csr -config $CONFIG_PATH -nodes
```

## Displaying content of a signing request

```bash
openssl req -text -in $CERT
```

## Displaying content of a certificate that a server presents

```bash
openssl s_client -showcerts -connect www.example.com:443
```

## Verifying that server certificate was signed by a CA

```bash
curl --cacert /var/lib/secret/ca.pem https://www.example:8443
```

## Signing certificate signing request

```bash
openssl x509 -req -days $DURATION -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -extfile $CONFIG_PATH
```

## Generate a signed certificate with keytool

```bash
# First create the keystore 
keytool -keystore keystore.server.jks -alias server -validity $DURATION -genkey -keyalg RSA

# Generate a certificate signing request and export it to a file
keytool -keystore keystore.server.jks -alias server -certreq -file $KEYSTORE_SIGN_REQUEST

# Sign the certificate request with OpenSSL and a CA
openssl x509 -req -CA ca.crt -CAkey ca.key -in $KEYSTORE_SIGN_REQUEST -out $KEYSTORE_SIGNED_CERT -days $VALIDITY_IN_DAYS -CAcreateserial

# Importing the signed certificate to the keystore
keytool -keystore $KEYSTORE_WORKING_DIRECTORY/$KEYSTORE_FILENAME -alias localhost -import -file $KEYSTORE_SIGNED_CERT
```

## Displaying content of a signed certificate

```bash
openssl x509 -text -in $CERT
```

## Importing signed certificate with its private key into a keystore

```bash
# Exporting certificate to PKCS12 format
openssl pkcs12 -export -in server.crt -inkey server.key -chain -CAfile ca.pem -name "kafka.confluent.local" -out server.p12 -password pass:$PASSWORD

# Importing PKCS12 into another keystore (or create it)
keytool -importkeystore -deststorepass $PASSWORD -destkeystore server.keystore.jks  -srckeystore server.p12 -deststoretype PKCS12  -srcstoretype PKCS12 -noprompt -srcstorepass $PASSWORD
```

## Import certificate into a keystore

```bash
keytool -keystore truststore.jks -alias $ALIAS -import -file $CRT_FILE -storepass $PASSWORD  -noprompt -storetype PKCS12 
```


## Example of OpenSSL configuration file to generate a CA

```
[ policy_match ]
countryName = match
stateOrProvinceName = match
organizationName = match
organizationalUnitName = optional
commonName = supplied
emailAddress = optional

[ req ]
prompt = no
distinguished_name = dn
default_md = sha256
default_bits = 4096
x509_extensions = v3_ca

[ dn ]
countryName = UK
organizationName = Confluent
localityName = London
commonName = kafka.confluent.local

[ v3_ca ]
subjectKeyIdentifier=hash
basicConstraints = critical,CA:true
authorityKeyIdentifier=keyid:always,issuer:always
keyUsage = critical,keyCertSign,cRLSign
```

## Example of OpenSSL configuration file to generate a server certificate

```
[req]
prompt = no
distinguished_name = dn
default_md = sha256
default_bits = 4096
req_extensions = v3_req

[ dn ]
countryName = UK
organizationName = Confluent
localityName = London
commonName=kafka.confluent.local

[ v3_req ]
subjectKeyIdentifier = hash
basicConstraints = CA:FALSE
nsComment = "OpenSSL Generated Certificate"
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1=kafka.confluent.local
```

## Example of OpenSSL configuration file to generate a client certificate

```
[req]
prompt = no
distinguished_name = dn
default_md = sha256
default_bits = 4096
req_extensions = v3_req

[ dn ]
countryName = UK
organizationName = Confluent
localityName = London
commonName=kafka.confluent.local

[ v3_req ]
subjectKeyIdentifier = hash
basicConstraints = CA:FALSE
nsComment = "OpenSSL Generated Certificate"
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
```
