FROM germanedge-docker.artifactory.new-solutions.com/edge-one/ge-ubuntu-generic:0.19.0

ARG zookeper_version=3.7.0

ENV ZOOKEEPER_VERSION=$zookeper_version
ENV PORT=2181
ENV SERVICENAME=zookeeper
ENV CONSUL_TAGS='"web","application","prometheus"'
ENV CONSUL_META_SCRAPE_PATH="\/metrics"
ENV CONSUL_META_SCRAPE_PORT="7071"
ENV FILEBEAT_ARGS='--E filebeat.inputs.2.paths=["/opt/zookeeper/logs/*.log"]'

USER root

#RUN mkdir /var/run/sshd
#RUN echo 'root:germanedge' | chpasswd
#RUN apt update; apt upgrade; apt install -y wget unzip openjdk-8-jre-headless wget supervisor docker.io openssh-server curl
RUN apt update; apt upgrade; apt install -y wget unzip openjdk-8-jre-headless wget supervisor curl
#RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
RUN rm -rf /var/lib/apt/lists/*
#RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d  && echo 'exit 101' >> /usr/sbin/policy-rc.d  && chmod +x /usr/sbin/policy-rc.d   && dpkg-divert --local --rename --add /sbin/initctl  && cp -a /usr/sbin/policy-rc.d /sbin/initctl  && sed -i 's/^exit.*/exit 0/' /sbin/initctl   && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup   && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean   && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages   && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes


#Download Zookeeper
RUN curl https://downloads.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -o /tmp/zookeeper.tar.gz \
  && tar -xzf /tmp/zookeeper.tar.gz -C /opt \
  && mv /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin /opt/zookeeper

#Configure
RUN mv /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ZK_HOME /opt/zookeeper
RUN sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

COPY --chown=edgeone:root start-zk.sh /usr/bin/start-zk.sh
#EXPOSE 2181 2888 3888


RUN mkdir -p /opt/prometheus/ \
  && curl https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar -o /opt/prometheus/jmx-exporter.jar

COPY --chown=edgeone:root prometheus_zk.yml /opt/prometheus/

ENV SERVER_JVMFLAGS='-javaagent:/opt/prometheus/jmx-exporter.jar=7071:/opt/prometheus/prometheus_zk.yml'


WORKDIR /opt/zookeeper
VOLUME ["/opt/zookeeper/conf", "/opt/zookeeper/data"]

USER 1000

COPY --chown=edgeone:root startup.sh /app/startup.sh
COPY --chown=edgeone:root service.json /app/service.json

RUN chmod +x /app/startup.sh

USER root 
