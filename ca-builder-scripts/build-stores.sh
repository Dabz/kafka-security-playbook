#!/usr/bin/env bash

IN_KEY="ca/intermediate/private/broker1.key.pem"
IN_CERT="ca/intermediate/certs/broker1.cert.pem"

CA_CERT="ca/certs/ca.cert.pem"
INT_CA_CERT="ca/intermediate/certs/intermediate.cert.pem"

mkdir stores tmp-certs

## buildind stores for the brokers
for i in kafka.confluent.local
do
openssl pkcs12 -export -in "ca/intermediate/certs/$i.cert.pem" -inkey "ca/intermediate/private/$i.key.pem" -passin pass:confluent -passout pass:confluent -name $i -out tmp-certs/$i.p12
sleep 1
## build keystore and truststores
keytool -noprompt -importkeystore -deststorepass confluent -destkeystore stores/broker.keystore -srckeystore tmp-certs/$i.p12 -srcstorepass confluent -storepass confluent -keypass confluent -srcstoretype PKCS12 -deststoretype pkcs12

done

openssl pkcs12 -export -in "ca/certs/ca.cert.pem" -inkey "ca/private/ca.key.pem" -passin pass:confluent -passout pass:confluent -name "ca" -out tmp-certs/ca.p12
sleep 1
openssl pkcs12 -export -in "ca/intermediate/certs/intermediate.cert.pem" -inkey "ca/intermediate/private/intermediate.key.pem" -passin pass:confluent -passout pass:confluent -name "intermediate-ca" -out tmp-certs/inter-ca.p12
sleep 1

keytool -noprompt -importkeystore -deststorepass confluent -destkeystore stores/broker.truststore -srckeystore tmp-certs/ca.p12 -srcstorepass confluent -srcstoretype PKCS12 -storepass confluent -keypass confluent -deststoretype pkcs12
sleep 1
keytool -noprompt -importkeystore -deststorepass confluent -destkeystore stores/broker.truststore -srckeystore tmp-certs/inter-ca.p12 -srcstorepass confluent -srcstoretype PKCS12 -storepass confluent -keypass confluent -deststoretype pkcs12


## building stores for the producers

for i in producer2
do
openssl pkcs12 -export -in "ca/intermediate/certs/$i.cert.pem" -inkey "ca/intermediate/private/$i.key.pem" -passin pass:confluent -passout pass:confluent -name $i -out tmp-certs/$i.p12
sleep 1
## build keystore and truststores
keytool -noprompt -importkeystore -deststorepass confluent -destkeystore stores/client.keystore -srckeystore tmp-certs/$i.p12 -srcstorepass confluent -storepass confluent -keypass confluent -srcstoretype PKCS12 -deststoretype pkcs12

done

openssl pkcs12 -export -in "ca/certs/ca.cert.pem" -inkey "ca/private/ca.key.pem" -passin pass:confluent -passout pass:confluent -name "ca" -out tmp-certs/ca.p12
sleep 1
openssl pkcs12 -export -in "ca/intermediate/certs/intermediate.cert.pem" -inkey "ca/intermediate/private/intermediate.key.pem" -passin pass:confluent -passout pass:confluent -name "intermediate-ca" -out tmp-certs/inter-ca.p12
sleep 1

keytool -noprompt -importkeystore -deststorepass confluent -destkeystore stores/client.truststore -srckeystore tmp-certs/ca.p12 -srcstorepass confluent -srcstoretype PKCS12 -storepass confluent -keypass confluent -deststoretype pkcs12
sleep 1
keytool -noprompt -importkeystore -deststorepass confluent -destkeystore stores/client.truststore -srckeystore tmp-certs/inter-ca.p12 -srcstorepass confluent -srcstoretype PKCS12 -storepass confluent -keypass confluent -deststoretype pkcs12
