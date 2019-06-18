FROM kerberos-demo/zookeeper-base

COPY zookeeper.sasl.jaas.config /etc/kafka/zookeeper_server_jaas.conf

# Set the ID for this ZK instance
RUN echo "2" > /var/lib/zookeeper/myid


#EXPOSE 2181
#CMD zookeeper-server-start /etc/kafka/zookeeper.properties
