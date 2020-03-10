# Kafka Connect REST api ssl client auth

One of the common question regarding security on Kafka Connect REST api is how to prevent unwanted access.
This playbook show one of the possible methods currently possible (as of November 2019) using the SSL mTLS feature.

## Requirements

To be able to execute this playbook you require:

* Docker (19.03 or later)
* Docker compose (1.24.1 or later)
* curl

## Bootstrap the playbook

The playbook bootstrap can be done by executing the ```./up``` script.

### Prepared TLS certificates and keystores

A set of prepared TLS certificates and keystores are available within the _connect/secrets_ directory.
Most relevant ones are:

* _certificate.p12_: TLS certificate to verify the failure of mTLS (this is a self sign certificate)
* _rest-client.p12_: TLS certificate to verify the positive verification using mTLS (this cert is sign by the same CA as the server identity)
* _server.keystore_ and _server.truststore_: keystores prepared for the Kafka Connect REST server identity.

All this certs has been created with the ca-builder-scripts.

## Verify the connectivity

To verify the connectivity there is a prepared script ```check-ssl-client-auth.sh```.
This script uses curl to verify a success and a failure authentication using mTLS
