#!/bin/bash
cd `dirname $0`
BIN_DIR=`pwd`
cd ..
DEPLOY_DIR=`pwd`
CONF_DIR=$DEPLOY_DIR/conf

SERVER_PORT=`sed '/server.port/!d;s/.*=//' conf/application.properties | tr -d '\r'`
SERVER_NAME=`sed '/spring.application.name/!d;s/.*=//' conf/application.properties | tr -d '\r'`
LOGS_FILE=`sed '/spring.logging.file/!d;s/.*=//' conf/application.properties | tr -d '\r'`
PROFILES_ACTIVE=`sed '/spring.profiles.active/!d;s/.*=//' conf/application.properties | tr -d '\r'`
SSL_ENABLED=`sed '/server.ssl.enabled/!d;s/.*=//' conf/application.properties | tr -d '\r'`
SSL_KEYSTORE=`sed '/server.ssl.key-store/!d;s/.*=//' conf/application.properties | tr -d '\r'`
SSL_KEYSTOREPASSWORD=`sed '/server.ssl.key-store-password/!d;s/.*=//' conf/application.properties | tr -d '\r'`
SPRING_CONFIG_LOCATION=$DEPLOY_DIR/conf/application-$PROFILES_ACTIVE.properties

if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME=`hostname`
fi

PIDS=$(ps -ef | grep java | grep $DEPLOY_DIR/lib/*.jar | grep -v grep | awk '{ print $2 }')
if [ -n "$PIDS" ]; then
    echo "ERROR: The $SERVER_NAME already started!"
    echo "PID: $PIDS"
    exit 1
fi

LOGS_DIR=""
if [ -n "$LOGS_FILE" ]; then
    LOGS_DIR=`dirname $LOGS_FILE`
else
    LOGS_DIR=$DEPLOY_DIR/logs
fi
if [ ! -d $LOGS_DIR ]; then
    mkdir $LOGS_DIR
fi
STDOUT_FILE=$LOGS_DIR/stdout.log

LIB_DIR=$DEPLOY_DIR/lib
LIB_JARS=`ls $LIB_DIR|grep .jar|awk '{print "'$LIB_DIR'/"$0}'|tr "\n" ":"`

JAVA_OPTS=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true "
JAVA_DEBUG_OPTS=""
if [ "$1" = "debug" ]; then
    JAVA_DEBUG_OPTS=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n "
fi
JAVA_JMX_OPTS=""
if [ "$1" = "jmx" ]; then
    JAVA_JMX_OPTS=" -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
fi
JAVA_MEM_OPTS=""
BITS=`java -version 2>&1 | grep -i 64-bit`
if [ -n "$BITS" ]; then
    JAVA_MEM_OPTS=" -server -Xms512m -Xmx512m -Xmn256m -XX:MetaspaceSize=128m -Xss256k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 "
else
    JAVA_MEM_OPTS=" -server -Xms1g -Xmx1g -XX:MetaspaceSize=128m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
fi

echo -e "Starting the $SERVER_NAME ...\c"
nohup java $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_DEBUG_OPTS $JAVA_JMX_OPTS -jar $LIB_DIR/*.jar --server.port=$SERVER_PORT --spring.application.name=$SERVER_NAME --logging.file=$LOGS_FILE --spring.profiles.active=$PROFILES_ACTIVE --server.ssl.enabled=$SSL_ENABLED --server.ssl.key-store=$SSL_KEYSTORE --server.ssl.key-store-password=$SSL_KEYSTOREPASSWORD --spring.config.location=$SPRING_CONFIG_LOCATION > $STDOUT_FILE 2>&1 &

echo "OK!"
PIDS=`ps -ef | grep java | grep "$DEPLOY_DIR" | awk '{print $2}'`
echo "PID: $PIDS"
echo "STDOUT: $STDOUT_FILE"
