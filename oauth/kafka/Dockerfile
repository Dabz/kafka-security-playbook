FROM centos
MAINTAINER d.gasparina@gmail.com
ENV container docker

# 1. Adding Confluent repository
RUN rpm --import https://packages.confluent.io/rpm/5.1/archive.key
COPY confluent.repo /etc/yum.repos.d/confluent.repo
RUN yum clean all

# 2. Install zookeeper and kafka
RUN yum install -y java-1.8.0-openjdk
RUN yum install -y confluent-kafka-2.11

# 3. Configure Kafka and zookeeper 
COPY server.properties /etc/kafka/server.properties
COPY client.properties /etc/kafka/client.properties
COPY kafka_server_jaas.conf /etc/kafka/kafka_server_jaas.conf
COPY oauthcallbackhandlers/target/dummy-oauth-adapter-0.1.0-jar-with-dependencies.jar /usr/share/java/kafka/dummy-oauth-adapter-0.1.0-jar-with-dependencies.jar
COPY test_produce_and_consume.sh /tmp/test_produce_and_consume.sh

# 4. Put SSL certificates in place
COPY kafka.server.keystore.jks /etc/kafka/kafka.server.keystore.jks
COPY kafka.server.truststore.jks /etc/kafka/kafka.server.truststore.jks
# this will be used by the kafka-console-producer.sh and kafka-console-consumer.sh scripts
COPY kafka.client.truststore.jks /etc/kafka/kafka.client.truststore.jks

EXPOSE 9093

CMD kafka-server-start /etc/kafka/server.properties
