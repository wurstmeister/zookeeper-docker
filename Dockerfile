FROM alpine

ENV ZOOKEEPER_VERSION="3.4.6" JAVA_HOME="/usr/lib/jvm/default-jvm"
ENV ZK_HOME /opt/zookeeper-${ZOOKEEPER_VERSION}

RUN \
 apk --update add openjdk8 gpgme bash && \
 wget -q http://mirror.vorboss.net/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz && \
 wget -q https://www.apache.org/dist/zookeeper/KEYS && \
 wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz.asc && \
 wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz.md5 && \
 md5sum -c zookeeper-${ZOOKEEPER_VERSION}.tar.gz.md5 && \
 gpg --import KEYS && \
 gpg --verify zookeeper-${ZOOKEEPER_VERSION}.tar.gz.asc && \
 mkdir /opt && \
 tar -xzf zookeeper-${ZOOKEEPER_VERSION}.tar.gz -C /opt && \
 mv /opt/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo_sample.cfg /opt/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo.cfg && \
 sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data && \
 apk del gpgme && rm -rf /var/cache/apk/*

ADD start-zk.sh /usr/bin/start-zk.sh 
EXPOSE 2181 2888 3888

VOLUME ["/opt/zookeeper-${ZOOKEEPER_VERSION}/conf", "/opt/zookeeper-${ZOOKEEPER_VERSION}/data"]

CMD ["/bin/sh", "/usr/bin/start-zk.sh"]
