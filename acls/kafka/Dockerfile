FROM confluentinc/cp-enterprise-kafka:5.4.0

MAINTAINER sven@confluent.io

# Make sure the log directory is world-writable
RUN echo "===> Creating authorizer logs dir ..." \
     && mkdir -p /var/log/kafka-auth-logs \
     && chmod -R ag+w /var/log/kafka-auth-logs

COPY log4j.properties.template /etc/confluent/docker/log4j.properties.template

COPY *.conf /tmp/

