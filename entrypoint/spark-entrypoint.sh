#!/bin/bash

COMMAND="${1:-}"

spark-termination() {
    source /entrypoint/spark-termination.sh $COMMAND
}

source /entrypoint/spark-wait_for_it.sh

source /entrypoint/hadoop-configure.sh

source /entrypoint/spark-configure.sh

source /entrypoint/spark-initialization.sh $COMMAND &

trap spark-termination SIGTERM HUP INT QUIT TERM

# Wait for any process to exit
wait -n
