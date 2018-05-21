# Kafka security playbook

This repository contains a set of docker images to demonstrate the security configuration of Kafka and the Confluent Platform. The purpose of this repository is *NOT* to provide production's ready images, it has been designed to be used as an example or a base configuration file for your configuration.

All images has been created from scratch without reusing previously created or official images, this, to emphasize code and configuration readability over reusability and best-practices. For more official images, I would recommend you to rely on the [Docker Images for the Confluent Platform] (https://github.com/confluentinc/cp-docker-images)


## TLS without authentication
TODO

## Kerberos (GSSAPI) authentication without TLS
This example contains a basic KDC server and configure both zookeeper and kafka with Kerberos and basics ACL. Credentials are created without password, a keytab containing credentials is available in a Docker volume named "secret". The following credential are automatically created in the KDC database:
1. kafka/admin@TEST.CONFLUENT.IO" - to access zookeeper
2. kafka_producer/producer@TEST.CONFLUENT.IO"  - to access kafka as a producer
3. kafka_consumer/consumer@TEST.CONFLUENT.IO"  - to access kafka as a consumer

### Usage
```bash
cd kerberos
# Scripts orchestrating the docker-compose services
./up
# Using kinit with a keytab for authentication then invoking kafka interfaces
docker-compose exec kafka bash -c 'kinit -k -t /var/lib/secret/kafka.key kafka_producer/producer && kafka-console-producer --broker-list kafka:9093 --topic test --producer.config /etc/kafka/consumer.properties'
docker-compose exec kafka bash -c 'kinit -k -t /var/lib/secret/kafka.key kafka_consumer/consumer && kafka-console-consumer --bootstrap-server kafka:9093 --topic test --consumer.config /etc/kafka/consumer.properties --from-beginning'
```

### Important configuration file
* [zookeeper properties] (kerberos/zookeeper/zookeeper.properties)
* [zookeeper server and client jaas configuration] (kerberos/zookeeper/zookeeper.sasl.jaas.config)
* [kafka server.properties] (kerberos/kafka/server.properties)
* [kafka server and client jaas configuration] (kerberos/kafka/kafka.sasl.jaas.config)
* [kafka consumer and producer configuration] (kerberos/kafka/consumer.properties)


## Kerberos (GSSAPI) authentication with TLS
TODO

## Scram authentication without TLS
TODO
