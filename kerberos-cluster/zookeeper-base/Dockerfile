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

# 3. Configure zookeeper for Kerberos
RUN yum install -y krb5-workstation krb5-libs

# 4. Copy in the zookeeper.properties as this is identical across the cluster:
COPY zookeeper.properties /etc/kafka/zookeeper.properties

# 5. Expose the required ports and set the entry point for the container:
EXPOSE 2181 2888 3888

CMD zookeeper-server-start /etc/kafka/zookeeper.properties
