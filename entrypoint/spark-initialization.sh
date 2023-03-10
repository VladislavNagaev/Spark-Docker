#!/bin/bash

COMMAND="${1:-}";

if [ "${COMMAND}" == "master" ]; then

    echo -e "${blue_b}Starting Spark master ...${reset_font}";

    source ${SPARK_HOME}/sbin/spark-config.sh;
    source ${SPARK_HOME}/bin/load-spark-env.sh;

    # ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.master.Master \
    # --host ${SPARK_MASTER_HOST} \
    # --port ${SPARK_MASTER_PORT:-7077} \
    # --webui-port ${SPARK_MASTER_WEBUI_PORT:-8080};

    "${SPARK_HOME}/sbin"/spark-daemon.sh start org.apache.spark.deploy.master.Master 1 \
    --host $SPARK_MASTER_HOST \
    --port $SPARK_MASTER_PORT \
    --webui-port $SPARK_MASTER_WEBUI_PORT;

    echo -e "${blue_b}Spark master started!${reset_font}";

    tail -f /dev/null;

fi;

if [ "${COMMAND}" == "worker" ]; then

    echo -e "${blue_b}Starting Spark worker ...${reset_font}";

    source ${SPARK_HOME}/sbin/spark-config.sh;
    source ${SPARK_HOME}/bin/load-spark-env.sh;

    # ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.worker.Worker \
    # --port ${SPARK_WORKER_PORT} \
    # --webui-port ${SPARK_WORKER_WEBUI_PORT} \
    # spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077};

    ${SPARK_HOME}/sbin/spark-daemon.sh start org.apache.spark.deploy.worker.Worker 1 \
    --port $SPARK_WORKER_PORT \
    --webui-port $SPARK_WORKER_WEBUI_PORT \
    spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077};

    echo -e "${blue_b}Spark worker started!${reset_font}";

    tail -f /dev/null;

fi;

if [ "${COMMAND}" == "historyserver" ]; then

    echo -e "${blue_b}Starting Spark historyserver ...${reset_font}";

    source ${SPARK_HOME}/sbin/spark-config.sh;
    source ${SPARK_HOME}/bin/load-spark-env.sh;

    SPARK_DEFAULTS_spark_eventLog_path=`echo ${SPARK_DEFAULTS_spark_eventLog_dir} | perl -pe 's#file://##'`;

    mkdir -p ${SPARK_DEFAULTS_spark_eventLog_path};

    # ${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.history.HistoryServer;

    ${SPARK_HOME}/sbin/spark-daemon.sh start org.apache.spark.deploy.history.HistoryServer 1;

    echo -e "${blue_b}Spark historyserver started!${reset_font}";

    tail -f /dev/null;

fi;

if [ "${COMMAND}" == "thriftserver" ]; then

    echo -e "${blue_b}Starting Spark thriftserver ...${reset_font}";

    # ${SPARK_HOME}/bin/spark-class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
    # spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077};

    ${SPARK_HOME}/sbin/spark-daemon.sh submit org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 1 \
    --name "Thrift JDBC/ODBC Server" \
    --master spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077};

    echo -e "${blue_b}Spark thriftserver started!${reset_font}";

    tail -f /dev/null;
    
fi;

exit $?;
