FROM ubuntu:latest

ARG zookeper_version=3.5.5
ARG consul_version=1.7.1
ARG hashicorp_releases=https://releases.hashicorp.com
ARG filebeat_version=7.5.0
ARG consul_url=consul

ENV ZOOKEEPER_VERSION=$zookeper_version \
    CONSUL_VERSION=$consul_version \
    HASHICORP_RELEASES=$hashicorp_releases \
    FILEBEAT_VERSION=$filebeat_version \
    CONSUL_URL=$consul_url


#RUN mkdir /var/run/sshd
#RUN echo 'root:germanedge' | chpasswd
#RUN apt update; apt upgrade; apt install -y wget unzip openjdk-8-jre-headless wget supervisor docker.io openssh-server curl
RUN apt update; apt upgrade; apt install -y wget unzip openjdk-8-jre-headless wget supervisor curl
#RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
RUN rm -rf /var/lib/apt/lists/*
#RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d  && echo 'exit 101' >> /usr/sbin/policy-rc.d  && chmod +x /usr/sbin/policy-rc.d   && dpkg-divert --local --rename --add /sbin/initctl  && cp -a /usr/sbin/policy-rc.d /sbin/initctl  && sed -i 's/^exit.*/exit 0/' /sbin/initctl   && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup   && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean   && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages   && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes


#Download Zookeeper
RUN wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz

#Install
RUN tar -xzf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -C /opt \
  && mv /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin /opt/zookeeper

#Configure
RUN mv /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ZK_HOME /opt/zookeeper
RUN sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

ADD start-zk.sh /usr/bin/start-zk.sh
#EXPOSE 2181 2888 3888

RUN curl -L -o /tmp/consul.zip ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip \
 && unzip -d /usr/bin /tmp/consul.zip && chmod +x /usr/bin/consul && rm /tmp/consul.zip \
 && mkdir -p /etc/consul.d/ \
 && mkdir -p /opt/consul-data/
 
ADD consul-zk.json /etc/consul.d/

RUN curl https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz -o /tmp/filebeat.tar.gz \
  && tar xzf /tmp/filebeat.tar.gz \
  && rm /tmp/filebeat.tar.gz \
  && mv filebeat-${FILEBEAT_VERSION}-linux-x86_64 /usr/share/filebeat \
  && cp /usr/share/filebeat/filebeat /usr/bin \
  && mkdir -p /etc/filebeat \
  && cp -a /usr/share/filebeat/module /etc/filebeat/
  
ADD filebeat.yml /etc/filebeat

RUN mkdir -p /opt/prometheus/ \
  && curl https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar -o /opt/prometheus/jmx-exporter.jar

ADD prometheus_zk.yml /opt/prometheus/

ENV SERVER_JVMFLAGS='-javaagent:/opt/prometheus/jmx-exporter.jar=7071:/opt/prometheus/prometheus_zk.yml'


WORKDIR /opt/zookeeper
VOLUME ["/opt/zookeeper/conf", "/opt/zookeeper/data"]


CMD bash /usr/bin/start-zk.sh
