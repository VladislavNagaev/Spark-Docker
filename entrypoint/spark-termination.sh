#!/bin/bash

COMMAND="${1:-}"

if [ "${COMMAND}" == "master" ]; then

    echo "Ending Spark master ..."

    source ${SPARK_HOME}/sbin/spark-config.sh
    
    ${SPARK_HOME}/sbin/spark-daemon.sh stop org.apache.spark.deploy.master.Master 1


fi

if [ "${COMMAND}" == "worker" ]; then

    echo "Ending Spark worker ..."

    source ${SPARK_HOME}/sbin/spark-config.sh
    source ${SPARK_HOME}/bin/load-spark-env.sh

    # kill `jps | grep "Worker" | cut -d " " -f 1`

    ${SPARK_HOME}/sbin/spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1

fi

if [ "${COMMAND}" == "historyserver" ]; then

    echo "Ending Spark historyserver ..."

    ${SPARK_HOME}/sbin/spark-daemon.sh stop org.apache.spark.deploy.history.HistoryServer 1

fi

if [ "${COMMAND}" == "thriftserver" ]; then

    echo "Ending Spark thriftserver ..."

    ${SPARK_HOME}/sbin/spark-daemon.sh stop org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 1

fi

exit $?

