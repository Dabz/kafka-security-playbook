FROM centos:centos7
MAINTAINER d.gasparina@gmail.com
ENV container docker

# 1. Adding Confluent repository
RUN rpm --import https://packages.confluent.io/rpm/6.0/archive.key
COPY confluent.repo /etc/yum.repos.d/confluent.repo
RUN yum clean all

# 2. Install zookeeper and kafka
RUN yum install -y java-11-openjdk
RUN yum install -y confluent-server

# 3. Configure Kafka 
COPY server.properties /etc/kafka/server.properties
COPY consumer.properties /etc/kafka/consumer.properties

# 4. Add kafkacat
COPY kafkacat /usr/local/bin
RUN chmod +x /usr/local/bin/kafkacat
COPY kafkacat.conf /etc/kafka/kafkacat.conf

EXPOSE 9093

CMD kafka-server-start /etc/kafka/server.properties
