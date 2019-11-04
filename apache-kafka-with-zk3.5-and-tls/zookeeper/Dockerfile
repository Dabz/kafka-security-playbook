FROM purbon/zookeeper:3.5.5
MAINTAINER pere.urbon@gmail.com
ENV container docker

# 2. Install zookeeper and kafka
RUN yum install -y java-11-openjdk


# 3. Configure zookeeper
COPY zoo.cfg "${ZK_HOME}/conf/zoo.cfg"

# 4. Add extra utility scripts

ENV PATH="/opt/tlsZkCli.sh:${PATH}"
COPY tlsZkCli.sh /opt/tlsZkCli.sh

EXPOSE 2182

CMD zkServer.sh start-foreground
