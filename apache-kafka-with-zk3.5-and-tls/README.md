# Apache Kafka 2.4 (trunk) with Zookeeper 3.5.5

This playbook show the current (as of August 2019) necessary steps to enable a secured TLS connection between an Apache Kafka broker and his corresponding
Apache Zookeeper counter part.

As of today, this only covers using Zookeeper 3.5.5 with the upcoming Apache Kafka 2.4 version. Using it in earlier versions is not properly tested.

## Run the playbook.

To run the playbook you need installed in your machine, docker, docker-compose.

The playbook can be started by running the _$> ./up_ script.


### Configuration on Apache ZooKeeper

Required environment variables:

```bash
SERVER_JVMFLAGS=-Dzookeeper.serverCnxnFactory=org.apache.zookeeper.server.NettyServerCnxnFactory
````

zoo.cfg file:

```bash
secureClientPort=2182
authProvider.1=org.apache.zookeeper.server.auth.X509AuthenticationProvider
ssl.trustStore.location=/var/lib/secret/truststore.jks
ssl.trustStore.password=test1234
ssl.keyStore.location=/var/lib/secret/zookeeper.jks
ssl.keyStore.password=test1234
ssl.clientAuth=true
```

### Configuration for Apache Kafka

Required environment variables:

```bash
KAFKA_OPTS=-Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty -Dzookeeper.client.secure=true -Dzookeeper.ssl.keyStore.location=/var/lib/secret/kafka.jks -Dzookeeper.ssl.keyStore.password=confluent -Dzookeeper.ssl.trustStore.location=/var/lib/secret/truststore.jks  -Dzookeeper.ssl.trustStore.password=confluent
```

server.properties file:

```
zookeeper.connect=zookeeper:2182
```

to use the secure port, a use can use both (but I would certainly not recommended as it water down security)

## Things pending..

* The current zookeeper migration tool works based on JAAS files, there is currently no option to set authentication in a different way. There is an issue open with Apache Kafka (https://issues.apache.org/jira/browse/KAFKA-8843) to fix this, as well as the required overall KIP https://cwiki.apache.org/confluence/display/KAFKA/KIP-515%3A+Enable+ZK+client+to+use+the+new+TLS+supported+authentication, currently under discussion.

* The https://cwiki.apache.org/confluence/display/KAFKA/KIP-515%3A+Enable+ZK+client+to+use+the+new+TLS+supported+authentication covers as well the challenge of configuring zookeeper TLS access, for the brokers, using environment variables. There is a change proposed to make things better.

*NOTE*: This playbook utilised a custom made Apache Kafka docker image, build from a trunk snapshot the 22 of August 2019. Currently Apache Kafka 2.4 is still not released. Changing based images will be easy when an official confluent image is released.  

## Reference

* https://cwiki.apache.org/confluence/display/ZOOKEEPER/ZooKeeper+SSL+User+Guide
* https://cwiki.apache.org/confluence/display/KAFKA/KIP-515%3A+Enable+ZK+client+to+use+the+new+TLS+supported+authentication
* https://issues.apache.org/jira/browse/KAFKA-8843
* https://github.com/apache/kafka/commit/d67495d6a7f4c5f7e8736a25d6a11a1c1bef8d87
