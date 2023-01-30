
# Find the java binary
if [ -n "${JAVA_HOME}" ]; then
  RUNNER="${JAVA_HOME}/bin/java"
else
  if [ "$(command -v java)" ]; then
    RUNNER="java"
  else
    echo "JAVA_HOME is not set" >&2
    exit 1
  fi
fi

# Find Spark jars.
if [ -d "${SPARK_HOME}/jars" ]; then
  SPARK_JARS_DIR="${SPARK_HOME}/jars"
else
  SPARK_JARS_DIR="${SPARK_HOME}/assembly/target/scala-$SPARK_SCALA_VERSION/jars"
fi

if [ ! -d "$SPARK_JARS_DIR" ] && [ -z "$SPARK_TESTING$SPARK_SQL_TESTING" ]; then
  echo "Failed to find Spark jars directory ($SPARK_JARS_DIR)." 1>&2
  echo "You need to build Spark with the target \"package\" before running this program." 1>&2
  exit 1
else
  LAUNCH_CLASSPATH="$SPARK_JARS_DIR/*"
fi

# Add the launcher build dir to the classpath if requested.
if [ -n "$SPARK_PREPEND_CLASSES" ]; then
  LAUNCH_CLASSPATH="${SPARK_HOME}/launcher/target/scala-$SPARK_SCALA_VERSION/classes:$LAUNCH_CLASSPATH"
fi



"$RUNNER" -Xmx128m $SPARK_LAUNCHER_OPTS -cp "$LAUNCH_CLASSPATH" org.apache.spark.launcher.Main "$@"


"$RUNNER" -Xmx128m 
$SPARK_LAUNCHER_OPTS 
-cp "$LAUNCH_CLASSPATH" 
org.apache.spark.launcher.Main

org.apache.spark.deploy.master.Master 
--host spark-master 
--port 7077 
--webui-port 8080 


RUNNER=/usr/lib/jvm/java/bin/java 
SPARK_LAUNCHER_OPTS="/opt/spark/conf/\
:/opt/spark/assembly/target/scala-2.12/jars/*\

:/etc/hadoop/\
:/opt/hadoop/share/hadoop/tools/lib/*\
:/opt/hadoop/share/hadoop/common/lib/*\
:/opt/hadoop/share/hadoop/common/*\
:/opt/hadoop/share/hadoop/hdfs/\
:/opt/hadoop/share/hadoop/hdfs/lib/*\
:/opt/hadoop/share/hadoop/hdfs/*\
:/opt/hadoop/share/hadoop/mapreduce/lib/*\
:/opt/hadoop/share/hadoop/mapreduce/*\
:/opt/hadoop/share/hadoop/yarn/\
:/opt/hadoop/share/hadoop/yarn/lib/*\
:/opt/hadoop/share/hadoop/yarn/*"

-Xmx1g 
org.apache.spark.deploy.master.Master --host spark-master --port 7077 --webui-port 8080
 

echo $(${HADOOP_HOME}/bin/hadoop classpath)
/etc/hadoop
:/opt/hadoop/share/hadoop/common/lib/*
:/opt/hadoop/share/hadoop/common/*
:/opt/hadoop/share/hadoop/hdfs
:/opt/hadoop/share/hadoop/hdfs/lib/*
:/opt/hadoop/share/hadoop/hdfs/*
:/opt/hadoop/share/hadoop/mapreduce/lib/*
:/opt/hadoop/share/hadoop/mapreduce/*
:/opt/hadoop/share/hadoop/yarn/lib/*
:/opt/hadoop/share/hadoop/yarn/*





org.apache.spark.deploy.worker.Worker --webui-port --port  spark://spark-master:7077 "$RUNNER" -Xmx128m $SPARK_LAUNCHER_OPTS -cp "$LAUNCH_CLASSPATH" 


/usr/lib/jvm/java/bin/java 
-cp 
-Xmx1g 

org.apache.spark.deploy.worker.Worker --webui-port --port  spark://spark-master:7077 0

 

${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.worker.Worker --webui-port ${SPARK_WORKER_WEBUI_PORT} --port ${SPARK_WORKER_PORT} \ spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077}

/usr/lib/jvm/java/bin/java 
-cp 
-Xmx1g 

org.apache.spark.deploy.worker.Worker --webui-port --port  spark://spark-master:7077 




1111
"$RUNNER" -Xmx128m $SPARK_LAUNCHER_OPTS -cp "$LAUNCH_CLASSPATH" org.apache.spark.launcher.Main
2222
org.apache.spark.deploy.worker.Worker --webui-port --port  spark://spark-master:7077
3333




"$RUNNER" -Xmx128m $SPARK_LAUNCHER_OPTS -cp "$LAUNCH_CLASSPATH" org.apache.spark.launcher.Main "$@"


build_command() {
  "$RUNNER" -Xmx128m $SPARK_LAUNCHER_OPTS -cp "$LAUNCH_CLASSPATH" org.apache.spark.launcher.Main "$@"
  printf "%d\0" $?
}

# Turn off posix mode since it does not allow process substitution
set +o posix
CMD=()
DELIM=$'\n'
CMD_START_FLAG="false"
while IFS= read -d "$DELIM" -r ARG; do
  if [ "$CMD_START_FLAG" == "true" ]; then
    CMD+=("$ARG")
  else
    if [ "$ARG" == $'\0' ]; then
      # After NULL character is consumed, change the delimiter and consume command string.
      DELIM=''
      CMD_START_FLAG="true"
    elif [ "$ARG" != "" ]; then
      echo "$ARG"
    fi
  fi
done < <(build_command "$@")

COUNT=${#CMD[@]}
LAST=$((COUNT - 1))
LAUNCHER_EXIT_CODE=${CMD[$LAST]}

# Certain JVM failures result in errors being printed to stdout (instead of stderr), which causes
# the code that parses the output of the launcher to get confused. In those cases, check if the
# exit code is an integer, and if it's not, handle it as a special error case.
if ! [[ $LAUNCHER_EXIT_CODE =~ ^[0-9]+$ ]]; then
  echo "${CMD[@]}" | head -n-1 1>&2
  exit 1
fi

if [ $LAUNCHER_EXIT_CODE != 0 ]; then
  exit $LAUNCHER_EXIT_CODE
fi

CMD=("${CMD[@]:0:$LAST}")
exec "${CMD[@]}"







