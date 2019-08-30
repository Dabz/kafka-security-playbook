FROM purbon/kafka
MAINTAINER pere.urbon@gmail.com
ENV container docker

# 1. Install openjdk
RUN yum install -y java-11-openjdk

# 2. Configure Kafka
COPY server.properties /etc/kafka/server.properties

EXPOSE 9092

CMD kafka-server-start.sh /etc/kafka/server.properties
