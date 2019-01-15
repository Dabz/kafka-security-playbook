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

# 3. Configure Kafka 
COPY server.properties /etc/kafka/server.properties
COPY kafka_server_jaas.conf /etc/kafka/kafka_server_jaas.conf
COPY consumer.properties /etc/kafka/consumer.properties
COPY create_client_properties.sh /etc/kafka/create_client_properties.sh

EXPOSE 9093

CMD kafka-server-start /etc/kafka/server.properties
