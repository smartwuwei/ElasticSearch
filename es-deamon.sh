#!/bin/sh
JAVA_HOME_DEF="./jdk1.8.0_65"
ES_HOME="./elasticsearch-1.7.3"
LOG_PATH=${ES_HOME}/logs/es-deamon.log
function echoLog(){
message=$1
echo -n $(date "+%Y/%m/%d %T") >> $LOG_PATH
echo " $message" >> $LOG_PATH
}
while true
do
pid=$(jps | grep Elasticsearch | cut -d ' ' -f 1)
if [ "$pid" = "" ]
then
echoLog "Elasticsearch Server was killed!"
export JAVA_HOME=$JAVA_HOME_DEF
${ES_HOME}/bin/elasticsearch -d
echoLog "Elasticsearch Server was restarted!"
fi
sleep 10
done

