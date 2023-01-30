#!/bin/bash

echo "Spark-node configuration started ..."


function configure_conffile() {

    local path=$1
    local envPrefix=$2

    local var
    local value
    
    echo "Configuring $path"

    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 

        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}

        echo " - Setting $name=$value"
        echo "${name} ${value}" | tee -a $path > /dev/null

    done
}


function configure_envfile() {

    local path=$1
    local -n envArray=$2

    local name
    local value

    echo "Configuring ${path}"

    for c in "${envArray[@]}"
    do

        name=${c}
        value=${!c}

        if [[ -n ${value} ]]; then
            echo " - Setting ${name}=${value}"
            echo "export ${name}=${value}" >> ${path}
        fi
    
    done
}



if ! [ -z ${SPARK_HOME+x} ]; then
    SPARK_CLASSPATH=${SPARK_HOME}/jars/*:${SPARK_CLASSPATH};
    echo "SPARK_CLASSPATH=${SPARK_CLASSPATH}";
fi

if ! [ -z ${HADOOP_CONF_DIR+x} ]; then
    SPARK_CLASSPATH=${HADOOP_CONF_DIR}:${SPARK_CLASSPATH};
    echo "SPARK_CLASSPATH=${SPARK_CLASSPATH}";
fi

if ! [ -z ${SPARK_CONF_DIR+x} ]; then
    SPARK_CLASSPATH=${SPARK_CONF_DIR}:${SPARK_CLASSPATH};
    echo "SPARK_CLASSPATH=${SPARK_CLASSPATH}";
elif ! [ -z ${SPARK_HOME+x} ]; then
    SPARK_CLASSPATH=${SPARK_HOME}/conf:${SPARK_CLASSPATH};
    echo "SPARK_CLASSPATH=${SPARK_CLASSPATH}";
fi


if ! [ -z ${SPARK_HOME/lib/native+x} ]; then
    SPARK_DAEMON_JAVA_OPTS="-Djava.library.path=${HADOOP_HOME}/lib/native";
    echo "SPARK_DAEMON_JAVA_OPTS=${SPARK_DAEMON_JAVA_OPTS}";
fi


if [ -n ${HADOOP_HOME} ] && [ -z ${SPARK_DIST_CLASSPATH} ]; then
    SPARK_DIST_CLASSPATH=$(${HADOOP_HOME}/bin/hadoop classpath);
    echo "SPARK_DIST_CLASSPATH=${SPARK_DIST_CLASSPATH}";
fi


if ! [ -z ${SPARK_PID_DIR+x} ]; then
    mkdir -p ${SPARK_PID_DIR};
    echo "SPARK_PID_DIR=${SPARK_PID_DIR}"
fi

if ! [ -z ${SPARK_LOG_DIR+x} ]; then
    mkdir -p ${SPARK_LOG_DIR};
    echo "SPARK_LOG_DIR=${SPARK_LOG_DIR}"
fi


if ! [ -z ${SPARK_CONF_DIR+x} ]; then
    touch ${SPARK_CONF_DIR}/spark-defaults.conf;
    configure_conffile ${SPARK_CONF_DIR}/spark-defaults.conf SPARK_DEFAULTS;
fi

if ! [ -z ${SPARK_CONF_DIR+x} ]; then

    declare -a SparkEnv=(
        "HADOOP_CONF_DIR" "SPARK_LOCAL_IP" "SPARK_PUBLIC_DNS" "SPARK_LOCAL_DIRS" 
        "MESOS_NATIVE_JAVA_LIBRARY" "SPARK_CONF_DIR" "YARN_CONF_DIR" "SPARK_EXECUTOR_CORES"
        "SPARK_EXECUTOR_MEMORY" "SPARK_DRIVER_MEMORY" "SPARK_MASTER_HOST" "SPARK_MASTER_PORT"
        "SPARK_MASTER_WEBUI_PORT" "SPARK_MASTER_OPTS" "SPARK_WORKER_CORES" "SPARK_WORKER_MEMORY"
        "SPARK_WORKER_PORT" "SPARK_WORKER_WEBUI_PORT" "SPARK_WORKER_DIR" "SPARK_WORKER_OPTS"
        "SPARK_DAEMON_MEMORY" "SPARK_HISTORY_OPTS" "SPARK_SHUFFLE_OPTS" "SPARK_DAEMON_JAVA_OPTS"
        "SPARK_DAEMON_CLASSPATH" "SPARK_LAUNCHER_OPTS" "SPARK_LOG_DIR" "SPARK_PID_DIR" 
        "SPARK_IDENT_STRING" "SPARK_NICENESS" "SPARK_NO_DAEMONIZE" "MKL_NUM_THREADS" 
        "OPENBLAS_NUM_THREADS"
    );

    touch ${SPARK_CONF_DIR}/spark-env.sh;
    configure_envfile ${SPARK_CONF_DIR}/spark-env.sh SparkEnv;

fi

# PYTHONPATH=${SPARK_HOME}/python:${PYTHONPATH}
# PYSPARK_PYTHON=/usr/bin/python3 \

echo "Spark-node configuration completed!"
