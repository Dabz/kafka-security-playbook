##!/usr/bin/env bash

export CLIENT_JVMFLAGS="-Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty  -Dzookeeper.client.secure=true
  -Dzookeeper.ssl.keyStore.location=/var/lib/secret/zookeeper.jks
  -Dzookeeper.ssl.keyStore.password=confluent
  -Dzookeeper.ssl.trustStore.location=/var/lib/secret/truststore.jks
  -Dzookeeper.ssl.trustStore.password=confluent"

zkCli.sh -server $1
