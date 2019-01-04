# Kafka security playbook

This repository contains a set of docker images to demonstrate the security configuration of Kafka and the Confluent Platform. The purpose of this repository is **NOT** to provide production's ready images. It has been designed to be used as an example and to assist peoples configuring the security module of Apache Kafka. 

All images has been created from scratch without reusing previously created images, this, to emphasize code and configuration readability over best-practices. For official images, I would recommend you to rely on the [Docker Images for the Confluent Platform](https://github.com/confluentinc/cp-docker-images)

## Plain authentication (challenge response)
Plain authentication is a simple mechanism based on username/password. It should be used with TLS for encryption to implement secure authentication. This playbook contains a simple configuration where SASL-Plain authentication is used for Kafka.

### Usage
```bash
cd plain
./up
kafka-console-producer --broker-list kafka:9093 --producer.config /etc/kafka/consumer.properties --topic test
kafka-console-consumer --bootstrap-server kafka:9093 --consumer.config /etc/kafka/consumer.properties --topic test --from-beginning
```

### Important configuration files
<details>
<summary><a href="plain/kafka/server.properties">kafka server.properties</a></summary>,
<pre>
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
allow.everyone.if.no.acl.found=false
super.users=User:kafka
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer
</pre>
</details>

<details>
<summary><a href="plain/kafka/consumer.properties">kafka consumer and producer configuration</a></summary>
<pre>
sasl.mechanism=PLAIN
security.protocol=SASL_PLAINTEXT
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
  username="kafka" \
password="kafka";
</pre>
</details>

<details>
<summary><a href="plain/kafka/kafka.jaas.config">kafka server jaas configuration</a></summary>
<pre>
KafkaServer {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="kafka"
   password="kafka"
   user_kafka="kafka"
   user_producer="producer-secret"
   user_consumer="consumer-secret";
};
</pre>
</details>

#### For further information
* [Confluent documentation on SASL Plain](https://docs.confluent.io/current/kafka/authentication_sasl_plain.html)


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

<details>
<summary><a href="scram/kafka/kafka.sasl.jaas.config">kafka server jaas configuration</a></summary>
<pre>
KafkaServer {
   org.apache.kafka.common.security.scram.ScramLoginModule required
   username="kafka"
   password="kafka";
};
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

#Avro consumer/producer using schema registry
docker-compose exec kafka kafka-avro-console-producer --broker-list kafka.confluent.local:9093 --topic avro_test --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}' --property schema.registry.url=https://schema-registry.confluent.local:8443 --producer.config /etc/kafka/consumer.properties
#example message: {"f1": "value1"}
kafka-avro-console-consumer --topic avro_test --from-beginning --property schema.registry.url=https://schema-registry.confluent.local:8443 --consumer.config /etc/kafka/consumer.properties --bootstrap-server kafka.confluent.local:9093

```

To connect from a producer/consumer running on your local machine:

```bash
docker-compose exec kafka kafka-acls --authorizer-properties zookeeper.connect=zookeeper.confluent.local:2181 --add --allow-principal User:CN=<YOUR LOCAL HOSTNAME>,L=London,O=Confluent,C=UK --operation All --topic '*' --cluster;
```
Set the following JVM parameters:

```
-Djavax.net.ssl.keyStore=<kafka-security-playbook DIR>/tls/certs/local-client.keystore.jks
-Djavax.net.ssl.trustStore=<kafka-security-playbook DIR>/tls/certs/truststore.jks
-Djavax.net.ssl.keyStorePassword=test1234
-Djavax.net.ssl.trustStorePassword=test1234
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

## Oauth authentication via TLS encryption

Kafka supports SASL authentication via Oauth bearer tokens. A sample playbook for secured oauth token authentication is contained in the oauth subfolder of this repository. 

### Usage

Prerequisites: jdk8, maven, docker-compose, openssl.
 
```bash
cd oauth
./up
```

In this sample playbook both the identity of brokers (`sasl.mechanism.inter.broker.protocol=OAUTHBEARER` within server.properties) and the identity of clients (`sasl.mechanism=OAUTHBEARER` within consumer.properties) are verified by the brokers using oauth bearer tokens. 

Within this sample playbook oauth bearer tokens are generated and validated using the `jjwt` library without communication to an authorization server. In real life, this would be different.

The class `OauthBearerLoginCallbackHandler` is used by the `kafka-console-producer`, `kafka-console-consumer` clients and by kafka brokers themselves to generate a JWT token using a shared secret. This class is configured within the `client.properties file:

Note that the client does not need to have a keystore configured, since client authentication is achieved using bearer tokens. 
Still it needs a truststore to verify the identity of the brokers. 

<details>
	<summary><a href="oauth/kafka/client.properties">kafka consumer and prodcuer configuration</a></summary>
<pre>
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.login.callback.handler.class=io.confluent.examples.authentication.oauth.OauthBearerLoginCallbackHandler
ssl.truststore.location=/etc/kafka/kafka.client.truststore.jks
ssl.truststore.password=secret
</pre>
</details>

The `OauthBearerLoginCallbackHandler` class is also configured for broker clients within the `server.properties` file (see below). The `server.properties` file must also include a reference to the token validator class (`OauthBearerValidatorCallbackHandler`):

<details>
	<summary><a href="oauth/kafka/server.properties">kafka broker configuration</a></summary>
<pre>
listeners=SASL_SSL://kafka.confluent.local:9093
advertised.listeners=SASL_SSL://kafka.confluent.local:9093
security.inter.broker.protocol=SASL_SSL
sasl.mechanism.inter.broker.protocol=OAUTHBEARER
sasl.enabled.mechanisms=OAUTHBEARER
listener.name.sasl_ssl.oauthbearer.sasl.server.callback.handler.class=io.confluent.examples.authentication.oauth.OauthBearerValidatorCallbackHandler
listener.name.sasl_ssl.oauthbearer.sasl.login.callback.handler.class=io.confluent.examples.authentication.oauth.OauthBearerLoginCallbackHandler
ssl.truststore.location=/etc/kafka/kafka.server.truststore.jks
ssl.truststore.password=secret
ssl.keystore.location=/etc/kafka/kafka.server.keystore.jks
ssl.keystore.password=secret
ssl.key.password=secret
</pre>
</details>

Kafka brokers need both a keystore configured to identify themselves to clients and other brokers as well as a truststore to verify the identity of broker clients. 

### Further information

* [Confluent documentation on Oauth authentication] (https://docs.confluent.io/current/kafka/authentication_sasl/authentication_sasl_oauth.html)
* [Blog Post] (https://medium.com/@jairsjunior/how-to-setup-oauth2-mechanism-to-a-kafka-broker-e42e72839fe)