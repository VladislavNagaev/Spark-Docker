#!/bin/bash

COMMAND="${1:-}";

if [ "${COMMAND}" == "master" ]; then

    echo -e "${blue_b}Ending Spark master ...${reset_font}";

    source ${SPARK_HOME}/sbin/spark-config.sh;
    
    ${SPARK_HOME}/sbin/spark-daemon.sh stop org.apache.spark.deploy.master.Master 1;

fi;

if [ "${COMMAND}" == "worker" ]; then

    echo -e "${blue_b}Ending Spark worker ...${reset_font}";

    source ${SPARK_HOME}/sbin/spark-config.sh;
    source ${SPARK_HOME}/bin/load-spark-env.sh;

    # kill `jps | grep "Worker" | cut -d " " -f 1`;

    ${SPARK_HOME}/sbin/spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1;

fi;

if [ "${COMMAND}" == "historyserver" ]; then

    echo -e "${blue_b}Ending Spark historyserver ...${reset_font}";

    ${SPARK_HOME}/sbin/spark-daemon.sh stop org.apache.spark.deploy.history.HistoryServer 1;

fi;

if [ "${COMMAND}" == "thriftserver" ]; then

    echo -e "${blue_b}Ending Spark thriftserver ...${reset_font}";

    ${SPARK_HOME}/sbin/spark-daemon.sh stop org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 1;

fi;

exit $?;

