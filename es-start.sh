#!/bin/sh
JAVA_HOME_DEF="./jdk1.8.0_65"
ES_HOME="./elasticsearch-1.7.3"
export JAVA_HOME=$JAVA_HOME_DEF
sh ./es-stop.sh
echo "start Elasticsearch"
${ES_HOME}/bin/elasticsearch -d
echo "start Deamon"
nohup sh ./es-deamon.sh &

