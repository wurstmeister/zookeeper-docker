FROM wurstmeister/base

MAINTAINER Wurstmeister

ENV ZOOKEEPER_VERSION 3.5.5

#Download Zookeeper
RUN wget -q http://mirror.vorboss.net/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz && \
wget -q https://www.apache.org/dist/zookeeper/KEYS && \
wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.asc && \
wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.sha512

#Verify download
RUN sha512sum -c apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.sha512 && \
gpg --import KEYS && \
gpg --verify apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.asc

#Install
RUN tar -xzf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -C /opt

#Configure
RUN mv /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin /opt/zookeeper-${ZOOKEEPER_VERSION}
RUN mv /opt/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo_sample.cfg /opt/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo.cfg

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ZK_HOME /opt/zookeeper-${ZOOKEEPER_VERSION}
RUN sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

ADD start-zk.sh /usr/bin/start-zk.sh 
EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper-${ZOOKEEPER_VERSION}
VOLUME ["/opt/zookeeper-${ZOOKEEPER_VERSION}/conf", "/opt/zookeeper-${ZOOKEEPER_VERSION}/data"]

CMD /usr/sbin/sshd && bash /usr/bin/start-zk.sh
