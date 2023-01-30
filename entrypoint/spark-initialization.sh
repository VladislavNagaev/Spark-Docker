#!/bin/bash

COMMAND="${1:-}"

if [ "${COMMAND}" == "master" ]; then

    echo "Starting Spark master ..."

    source ${SPARK_HOME}/sbin/spark-config.sh
    source ${SPARK_HOME}/bin/load-spark-env.sh

    # ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.master.Master \
    # --host ${SPARK_MASTER_HOST} \
    # --port ${SPARK_MASTER_PORT:-7077} \
    # --webui-port ${SPARK_MASTER_WEBUI_PORT:-8080}

    "${SPARK_HOME}/sbin"/spark-daemon.sh start org.apache.spark.deploy.master.Master 1 \
    --host $SPARK_MASTER_HOST \
    --port $SPARK_MASTER_PORT \
    --webui-port $SPARK_MASTER_WEBUI_PORT

    echo "Spark master started!"

    tail -f /dev/null

fi

if [ "${COMMAND}" == "worker" ]; then

    echo "Starting Spark worker ..."

    source ${SPARK_HOME}/sbin/spark-config.sh
    source ${SPARK_HOME}/bin/load-spark-env.sh

    # ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.worker.Worker \
    # --port ${SPARK_WORKER_PORT} \
    # --webui-port ${SPARK_WORKER_WEBUI_PORT} \
    # spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077}

    ${SPARK_HOME}/sbin/spark-daemon.sh start org.apache.spark.deploy.worker.Worker 1 \
    --port $SPARK_WORKER_PORT \
    --webui-port $SPARK_WORKER_WEBUI_PORT \
    spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077}

    echo "Spark worker started!"

    tail -f /dev/null

fi

if [ "${COMMAND}" == "historyserver" ]; then

    echo "Starting Spark historyserver ..."

    source ${SPARK_HOME}/sbin/spark-config.sh
    source ${SPARK_HOME}/bin/load-spark-env.sh

    SPARK_DEFAULTS_spark_eventLog_path=`echo ${SPARK_DEFAULTS_spark_eventLog_dir} | perl -pe 's#file://##'`

    mkdir -p ${SPARK_DEFAULTS_spark_eventLog_path}

    # ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.history.HistoryServer

    ${SPARK_HOME}/sbin/spark-daemon.sh start org.apache.spark.deploy.history.HistoryServer 1

    echo "Spark historyserver started!"

    tail -f /dev/null

fi

if [ "${COMMAND}" == "thriftserver" ]; then

    echo "Starting Spark thriftserver ..."

    # ${SPARK_HOME}/bin/spark-class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
    # spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077}

    ${SPARK_HOME}/sbin/spark-daemon.sh submit org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 1 \
    --name "Thrift JDBC/ODBC Server" \
    --master spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077}

    echo "Spark thriftserver started!"

    tail -f /dev/null
    
fi

exit $?
