#!/bin/sh
PARAM=$1
JAVA_HOME_DEF="./jdk1.8.0_65"
ES_HOME="./elasticsearch-1.7.3"
export JAVA_HOME=$JAVA_HOME_DEF
${ES_HOME}/bin/plugin $PARAM

