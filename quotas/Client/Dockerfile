FROM centos
MAINTAINER seknop@gmail.com
ENV container docker

# 1. Adding Confluent repository
RUN rpm --import https://packages.confluent.io/rpm/5.1/archive.key
COPY confluent.repo /etc/yum.repos.d/confluent.repo
RUN yum clean all

# 2. Install Confluent Kafka stack
RUN yum install -y java-1.8.0-openjdk
RUN yum install -y confluent-kafka-2.11

CMD tail -f /dev/null
