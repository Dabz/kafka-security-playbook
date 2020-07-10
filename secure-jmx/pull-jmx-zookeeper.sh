#!/usr/bin/env bash

MY_KAFKA_OPTS="-Djavax.net.ssl.keyStore=/var/ssl/private/kafka.keystore -Djavax.net.ssl.keyStorePassword=confluent -Djavax.net.ssl.trustStore=/var/ssl/private/kafka.truststore -Djavax.net.ssl.trustStorePassword=confluent"

docker-compose exec -e KAFKA_JMX_OPTS="" -e KAFKA_OPTS="$MY_KAFKA_OPTS" zookeeper kafka-run-class kafka.tools.JmxTool \
    --object-name org.apache.ZooKeeperService:name0=StandaloneServer_port2181 \
    --jmx-ssl-enable true --jmx-auth-prop admin=adminpassword


#get -s -b org.apache.ZooKeeperService:name0=StandaloneServer_port2181 AvgRequestLatency
