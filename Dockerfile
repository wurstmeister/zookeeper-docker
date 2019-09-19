FROM ubuntu:latest


ENV ZOOKEEPER_VERSION=3.5.5

RUN mkdir /var/run/sshd
RUN echo 'root:germanedge' | chpasswd
RUN apt update; apt upgrade; apt install -y wget unzip openjdk-8-jre-headless wget supervisor docker.io openssh-server
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
RUN rm -rf /var/lib/apt/lists/*
RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d  && echo 'exit 101' >> /usr/sbin/policy-rc.d  && chmod +x /usr/sbin/policy-rc.d   && dpkg-divert --local --rename --add /sbin/initctl  && cp -a /usr/sbin/policy-rc.d /sbin/initctl  && sed -i 's/^exit.*/exit 0/' /sbin/initctl   && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup   && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean   && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages   && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes


#Download Zookeeper
RUN wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz

#Install
RUN tar -xzf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -C /opt

RUN mv /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin /opt/zookeeper

#Configure
RUN mv /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ZK_HOME /opt/zookeeper
RUN sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

ADD start-zk.sh /usr/bin/start-zk.sh
#EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper
VOLUME ["/opt/zookeeper/conf", "/opt/zookeeper/data"]


CMD /usr/sbin/sshd && bash /usr/bin/start-zk.sh
