FROM centos
MAINTAINER seknop@gmail.com
ENV container docker

# 1. Adding Confluent repository
RUN rpm --import https://packages.confluent.io/rpm/5.4/archive.key
COPY confluent.repo /etc/yum.repos.d/confluent.repo
RUN yum clean all

# 2. Install zookeeper and kafka
RUN yum install -y java-11-openjdk-devel
RUN yum install -y confluent-server

# 3. Configure Kafka and zookeeper for Kerberos
COPY server.properties /etc/kafka/server.properties
COPY server-with-ssl.properties /etc/kafka/server-with-ssl.properties
COPY kafka.jaas.config /etc/kafka/kafka_server_jaas.conf
COPY log4j.properties /etc/kafka/log4j.properties

COPY alice.properties /etc/kafka/alice.properties
COPY barnie.properties /etc/kafka/barnie.properties
COPY charlie.properties /etc/kafka/charlie.properties
COPY kafka.properties /etc/kafka/kafka.properties

EXPOSE 9093

CMD kafka-server-start /etc/kafka/server.properties
