#!/bin/sh

sed -i -r 's|#(log4j.appender.ROLLINGFILE.MaxBackupIndex.*)|\1|g' $ZK_HOME/conf/log4j.properties
sed -i -r 's|#autopurge|autopurge|g' $ZK_HOME/conf/zoo.cfg
sed -i -r 's|(zookeeper.root.logger=.*)|\1, ROLLINGFILE|g' $ZK_HOME/conf/log4j.properties
sed -i -r 's|(zookeeper.log.maxfilesize=.*)|zookeeper.log.maxfilesize=16MB|g' $ZK_HOME/conf/log4j.properties
export ZOO_LOG4J_PROP="INFO,CONSOLE,ROLLINGFILE"


/opt/zookeeper/bin/zkServer.sh start-foreground
