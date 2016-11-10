#!/bin/sh
echo "stop Deamon"
dpid=$(ps -ef | grep es-deamon.sh | grep -v grep | sed 's/[ ]\+/ /g' | cut -d ' ' -f 2)
if [ "$dpid" != "" ]
then
echo "kill Deamon pid=$dpid"
kill -9 $dpid
fi
echo "stop Elasticsearch"
pid=$(jps | grep Elasticsearch | cut -d ' ' -f 1)
if [ "$pid" != "" ]
then
echo "kill Elasticsearch pid=$pid"
kill -9 $pid
fi

