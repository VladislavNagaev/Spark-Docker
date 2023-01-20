#!/bin/bash

COMMAND="${1:-}"

source ${SPARK_HOME}/sbin/spark-config.sh
source ${SPARK_HOME}/bin/load-spark-env.sh

if [ "${COMMAND}" == "master" ]; then

    echo "Starting Spark master ..."

    ln -sf /dev/stdout ${LOG_DIRECTORY}/spark-master.out

    ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.master.Master \
    --host "${SPARK_MASTER_HOST}" \
    --port ${SPARK_MASTER_PORT:-7077} \
    --webui-port ${SPARK_MASTER_WEBUI_PORT:-8080} \
    >> ${LOG_DIRECTORY}/spark-master.out

fi

if [ "${COMMAND}" == "worker" ]; then

    echo "Starting Spark worker ..."

    ln -sf /dev/stdout ${LOG_DIRECTORY}/spark-worker.out

    ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.worker.Worker \
    spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077} \
    >> ${LOG_DIRECTORY}/spark-worker.out

fi

if [ "${COMMAND}" == "historyserver" ]; then

    echo "Starting Spark historyserver ..."

    SPARK_DEFAULTS_spark_eventLog_path=`echo ${SPARK_DEFAULTS_spark_eventLog_dir} | perl -pe 's#file://##'`

    mkdir -p ${SPARK_DEFAULTS_spark_eventLog_path}

    ln -sf /dev/stdout ${LOG_DIRECTORY}/spark-historyserver.out

    ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.history.HistoryServer \
    >> ${LOG_DIRECTORY}/spark-historyserver.out

fi


