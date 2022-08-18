#
# Copyright 2019 Confluent Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG DOCKER_UPSTREAM_REGISTRY
ARG DOCKER_UPSTREAM_TAG=7.2.1

FROM ${DOCKER_UPSTREAM_REGISTRY}confluentinc/cp-base-new:${DOCKER_UPSTREAM_TAG}

ARG PROJECT_VERSION
ARG ARTIFACT_ID
ARG GIT_COMMIT

LABEL maintainer="partner-support@confluent.io"
LABEL vendor="Confluent"
LABEL version=$GIT_COMMIT
LABEL release=$PROJECT_VERSION
LABEL name=$ARTIFACT_ID
LABEL summary="Confluent platform Kafka."
LABEL io.confluent.docker=true
LABEL io.confluent.docker.git.id=$GIT_COMMIT
ARG BUILD_NUMBER=-1
LABEL io.confluent.docker.build.number=$BUILD_NUMBER
LABEL io.confluent.docker.git.repo="confluentinc/kafka-images"

ARG CONFLUENT_VERSION=7.2.1
ARG CONFLUENT_PACKAGES_REPO=https://packages.confluent.io/rpm/7.2
ARG CONFLUENT_PLATFORM_LABEL=7.2.1

ENV COMPONENT=kafka

# primary
EXPOSE 9092

USER root

RUN echo "===> Installing ${COMPONENT}..." \
    && echo "===> Adding confluent repository...${CONFLUENT_PACKAGES_REPO}" \
    && rpm --import ${CONFLUENT_PACKAGES_REPO}/archive.key \
    && printf "[Confluent.dist] \n\
name=Confluent repository (dist) \n\
baseurl=${CONFLUENT_PACKAGES_REPO}/\$releasever \n\
gpgcheck=1 \n\
gpgkey=${CONFLUENT_PACKAGES_REPO}/archive.key \n\
enabled=1 \n\
\n\
[Confluent] \n\
name=Confluent repository \n\
baseurl=${CONFLUENT_PACKAGES_REPO}/ \n\
gpgcheck=1 \n\
gpgkey=${CONFLUENT_PACKAGES_REPO}/archive.key \n\
enabled=1 " > /etc/yum.repos.d/confluent.repo \
    && yum install -y confluent-kafka-${CONFLUENT_VERSION} \
    && echo "===> clean up ..."  \
    && yum clean all \
    && rm -rf /tmp/* /etc/yum.repos.d/confluent.repo \
    && echo "===> Setting up ${COMPONENT} dirs" \
    && mkdir -p /var/lib/${COMPONENT}/data /etc/${COMPONENT}/secrets \
    && chown appuser:root -R /etc/kafka /var/log/kafka /var/log/confluent /var/lib/kafka /var/lib/zookeeper /etc/${COMPONENT}/secrets /var/lib/${COMPONENT} /etc/${COMPONENT} \
    && chmod -R ug+w /etc/kafka /var/log/kafka /var/log/confluent /var/lib/kafka /var/lib/zookeeper /var/lib/${COMPONENT} /etc/${COMPONENT}/secrets /etc/${COMPONENT}

VOLUME ["/var/lib/${COMPONENT}/data", "/etc/${COMPONENT}/secrets"]

COPY --chown=appuser:appuser include/etc/confluent/docker /etc/confluent/docker

USER appuser

CMD ["/etc/confluent/docker/run"]
