# TLS with CRL support in Apache Kafka

This is a playbook, or example to use Apache Kafka with TLS and take advantage of the Certificate Revocation list future.

## The distribution points

This playbook include a web server that serves the content of the [web/](web/) directory, the certificate revocation list file (_.pem_) should be made available in this directory.

## In Apache Kafka

Apache Kafka rely on the JVM to support certificate revocation lists, so we need to configure it accordingly. For this we need to pass as Kafka options:

```bash
KAFKA_OPTS=-Dcom.sun.security.enableCRLDP=true -Dcom.sun.net.ssl.checkRevocation=true
```

this will enable the CRL's and the check for the revocation.

This lists are going to be cached internally in the JVM for as long as 30s, see https://github.com/AdoptOpenJDK/openjdk-jdk11/blob/master/src/java.base/share/classes/sun/security/provider/certpath/URICertStore.java#L94 as reference.

## How do I generate the scripts for this

To generate this scripts you need a CA that include in their certificates the necessary CRL extensions, they should look something like:

```
[ crl_ext ]
# Extension for CRLs (`man x509v3_config`).
authorityKeyIdentifier=keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (`man ocsp`).
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
```

the first is for CRL, while the second is for OCSP.

This can be provided by for example:

* The scripts available in the [ca-builder-scripts/](../../ca-builder-scripts/), refer to their README for details.
* You can as well use the https://www.vaultproject.io, to build a custom CA.

Then you should make this certs available as java key stores to the brokers and clients here, and keep an updated list of revoked certs inside the [web/](web/) directory to be served and available for your clients.

## Running this playbook

This directory contains working keystores for the broker and the clients, as well a revoked certs list, that can be used to see how this flow works.
