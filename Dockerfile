ARG java_version=11-jre-slim

FROM openjdk:${java_version}

ARG zookeeper_version=3.7.0
ARG vcs_ref=unspecified
ARG build_date=unspecified

LABEL org.label-schema.name="zookeeper" \
      org.label-schema.description="Apache Zookeeper" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/wurstmeister/zookeeper-docker" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      org.label-schema.version="${java_version}_${zookeeper_version}}" \
      org.label-schema.schema-version="1.0" \
      maintainer="wurstmeister"

ENV ZOOKEEPER_VERSION=$zookeeper_version

# Install deps
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ssh \
    && mkdir -p /run/sshd \
    && rm -rf /var/lib/apt/lists/*

# Download Zookeeper
RUN wget -q https://mirror.vorboss.net/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz && \
    wget -q https://www.apache.org/dist/zookeeper/KEYS && \
    wget -q https://downloads.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.asc && \
    wget -q https://downloads.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.sha512

# Verify download
RUN sha512sum -c apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.sha512 && \
    gpg --import KEYS && \
    gpg --verify apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.asc

# Install
RUN tar -xzf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -C /opt && \
    mv /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin /opt/zookeeper

# Configure
RUN mv /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg

ENV ZK_HOME /opt/zookeeper
RUN sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

ADD start-zk.sh /usr/bin/start-zk.sh 
EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper
VOLUME ["/opt/zookeeper/conf", "/opt/zookeeper/data"]

CMD /usr/sbin/sshd && bash /usr/bin/start-zk.sh
