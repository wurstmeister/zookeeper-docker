FROM wurstmeister/base

MAINTAINER Wurstmeister

ENV ZOOKEEPER_VERSION=3.5.5

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
EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper
VOLUME ["/opt/zookeeper/conf", "/opt/zookeeper/data"]

CMD /usr/sbin/sshd && bash /usr/bin/start-zk.sh
