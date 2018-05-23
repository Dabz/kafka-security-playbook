# Kafka security playbook

This repository contains a set of docker images to demonstrate the security configuration of Kafka and the Confluent Platform. The purpose of this repository is **NOT** to provide production's ready images. It has been designed to be used as an example and to assist peoples configuring the security module of Apache Kafka. 

All images has been created from scratch without reusing previously created images, this, to emphasize code and configuration readability over best-practices. For official images, I would recommend you to rely on the [Docker Images for the Confluent Platform](https://github.com/confluentinc/cp-docker-images)

## Scram authentication (challenge response)
Scram is an authentication mechanism that perform username/password authentication in a secure way. This playbook contains a simple configuration where SASL-Scram authentication is used for Zookeeper and Kafka. In it:
* kafka use a username/password to connect to zookeeper
* consumer and producer must use a username/password to access the cluster

### Usage
```bash
cd scram
# Scripts starting the docker services and generating the kafka user
./up
docker-compose exec kafka kafka-console-producer --broker-list kafka:9093 --producer.config /etc/kafka/consumer.properties --topic test
docker-compose exec kafka kafka-console-consumer --bootstrap-server kafka:9093 --consumer.config /etc/kafka/consumer.properties --topic test --from-beginning
```

### Important configuration files
<details>
<summary><a href="scram/kafka/server.properties">kafka server.properties</a></summary>
<pre>
sasl.enabled.mechanisms=SCRAM-SHA-256
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-256
security.inter.broker.protocol=SASL_PLAINTEXT
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
</pre>
</details>

<details>
<summary><a href="scram/kafka/consumer.properties">kafka consumer and producer configuration</a></summary>
<pre>
sasl.mechanism=SCRAM-SHA-256
security.protocol=SASL_PLAINTEXT
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
  username="kafka" \
  password="kafka";
</pre>
</details>
	
#### For further information
* [Confluent documentation on SASL Scram](https://docs.confluent.io/current/kafka/authentication_sasl_scram.html)
* [Zookeeper documentation on SASL Scram](https://cwiki.apache.org/confluence/display/ZOOKEEPER/Client-Server+mutual+authentication)

## TLS with x509 authentication
TLS, previously known as SSL, is a cryptography protocol providing network encryption via asymetric certificates and keys.
This playbook contains a basic configuration to enforce TLS between the broker and a client. Be aware that right now zookeeper didn't release TLS as an official feature, thus only the broker is configured for TLS. In this playbook, TLS is used for both encryption, authentication and authorization. the _up_ script generates the following file before starting docker-compose services:
1. __certs/ca.key, certs/ca.crt__ - public and private key of the certificate authority
2. __certs/server.keystore.jks__ - keystore containing the signed certificate of the kafka broker  
3. __certs/client.keystore.jks__ - keystore containing the signed certificate of a kafka client. It has been granted super user permision   


### Usage
```bash
cd tls
# Scripts generating the required certificate and starting docker-compose services
./up
docker-compose exec kafka kafka-console-producer --broker-list kafka.confluent.local:9093 --topic test --producer.config /etc/kafka/consumer.properties
docker-compose exec kafka kafka-console-consumer --bootstrap-server kafka.confluent.local:9093 --topic test --consumer.config /etc/kafka/consumer.properties --from-beginning
```

### Important configuration files
<details>
<summary><a href="tls/kafka/server.properties"> kafka server.properties</a></summary>
<pre>
listeners=SSL://kafka.confluent.local:9093
advertised.listeners=SSL://kafka.confluent.local:9093
security.inter.broker.protocol=SSL
ssl.truststore.location=/var/lib/secret/truststore.jks
ssl.truststore.password=test1234
ssl.keystore.location=/var/lib/secret/server.keystore.jks
ssl.keystore.password=test1234
ssl.client.auth=required
# To use TLS based authorization
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
super.users=User:CN=kafka.confluent.local,L=London,O=Confluent,C=UK
</pre>
</details>
<details>
<summary><a href="tls/kafka/consumer.properties">kafka consumer and producer configuration</a></summary>
<pre>
bootstrap.servers=kafka.conflent.local:9093
security.protocol=SSL
ssl.truststore.location=/var/lib/secret/truststore.jks
ssl.truststore.password=test1234
ssl.keystore.location=/var/lib/secret/client.keystore.jks
ssl.keystore.password=test1234
ssl.key.password=test1234
</pre>
</details>

#### For further information
* [kafka documentation on TLS](http://kafka.apache.org/documentation.html#security_ssl)
* [Confluent documentation on TLS authentication](https://docs.confluent.io/current/kafka/authentication_ssl.html)
* [Confluent documentation on TLS key generation](https://docs.confluent.io/current/tutorials/security_tutorial.html#generating-keys-certs)

## Kerberos (GSSAPI) authentication without TLS
This example contains a basic KDC server and configure both zookeeper and kafka with Kerberos authentication and authorization. Credentials are created without password, a keytab containing credentials is available in a Docker volume named "secret". The following credential are automatically created in the KDC database:
1. __kafka/admin__ - to access zookeeper
2. __kafka_producer/producer__  - to access kafka as a producer
3. __kafka_consumer/consumer__  - to access kafka as a consumer

### Usage
```bash
cd kerberos
# Scripts orchestrating the docker-compose services
./up
# Using kinit with a keytab for authentication then invoking kafka interfaces
docker-compose exec kafka bash -c 'kinit -k -t /var/lib/secret/kafka.key kafka_producer/producer && kafka-console-producer --broker-list kafka:9093 --topic test --producer.config /etc/kafka/consumer.properties'
docker-compose exec kafka bash -c 'kinit -k -t /var/lib/secret/kafka.key kafka_consumer/consumer && kafka-console-consumer --bootstrap-server kafka:9093 --topic test --consumer.config /etc/kafka/consumer.properties --from-beginning'
```

### Important configuration files
<details>
<summary><a href="kerberos/zookeeper/zookeeper.properties">zookeeper properties</a></summary>
<pre>
authProvider.1 = org.apache.zookeeper.server.auth.SASLAuthenticationProvider
requireClientAuthScheme=sasl
</pre>
</details>
<details>
<summary><a href="kerberos/zookeeper/zookeeper.sasl.jaas.config">zookeeper server and client jaas configuration</a></summary>
<pre>
Server {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
		useTicketCache=false
    keyTab="/var/lib/secret/kafka.key"
    principal="zookeeper/zookeeper.kerberos_default@TEST.CONFLUENT.IO";
};
</pre>
</details>
<details>
<summary><a href="kerberos/kafka/server.properties">kafka server.properties</a></summary>
<pre>
listeners=SASL_PLAINTEXT://kafka:9093
advertised.listeners=SASL_PLAINTEXT://kafka:9093
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.enabled.mechanisms=GSSAPI
sasl.mechanism.inter.broker.protocol=GSSAPI
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.kerberos.service.name=kafka
allow.everyone.if.no.acl.found=false
super.users=User:admin;User:kafka
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
</pre>
</details>
<details>
<summary><a href="kerberos/kafka/kafka.sasl.jaas.config">kafka server and client jaas configuration</a></summary>
<pre>
/*
 * Cluster kerberos services
 */
KafkaServer {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
    keyTab="/var/lib/secret/kafka.key"
    principal="kafka/kafka.kerberos_default@TEST.CONFLUENT.IO";
};

/*
 * For client and broker identificatoin
 */
KafkaClient {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
    keyTab="/var/lib/secret/kafka.key"
    principal="admin/kafka.kerberos_default@TEST.CONFLUENT.IO";
};

/*
 * For Zookeeper authentication
 */
Client {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
		useTicketCache=false
    keyTab="/var/lib/secret/kafka.key"
    principal="kafka/kafka.kerberos_default@TEST.CONFLUENT.IO";
};
</pre>
</details>
<details>
	<summary><a href="kerberos/kafka/consumer.properties">kafka consumer and producer configuration</a></summary>
<pre>
bootstrap.servers=kafka:9093
security.protocol=SASL_PLAINTEXT
sasl.kerberos.service.name=kafka
sasl.jaas.config=com.sun.security.auth.module.Krb5LoginModule required \
								 useTicketCache=true
</pre>
</details>


#### For further information
* [Confluent documentation on GSSAPI authentication](https://docs.confluent.io/current/kafka/authentication_sasl_gssapi.html)
* [Confluent documentation on ACL](https://docs.confluent.io/current/kafka/authorization.html)
