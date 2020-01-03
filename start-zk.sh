#!/bin/sh

IP=$(hostname -i)
echo ip=$IP

consul agent -bind=$IP -join $CONSUL_URL -data-dir /opt/consul-data  -config-dir /etc/consul.d &

filebeat -e -c /etc/filebeat/filebeat.yml -path.home /usr/share/filebeat -path.config /etc/filebeat -path.data /var/lib/filebeat -path.logs /var/log/filebeat &

sed -i -r 's|#(log4j.appender.ROLLINGFILE.MaxBackupIndex.*)|\1|g' $ZK_HOME/conf/log4j.properties
sed -i -r 's|#autopurge|autopurge|g' $ZK_HOME/conf/zoo.cfg
sed -i -r 's|(zookeeper.root.logger=.*)|\1, ROLLINGFILE|g' $ZK_HOME/conf/log4j.properties
sed -i -r 's|(zookeeper.log.maxfilesize=.*)|zookeeper.log.maxfilesize=16MB|g' $ZK_HOME/conf/log4j.properties
export ZOO_LOG4J_PROP="INFO,CONSOLE,ROLLINGFILE"


/opt/zookeeper/bin/zkServer.sh start-foreground
