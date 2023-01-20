# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 hadoop-base:3.3.4

LABEL maintainer="Vladislav Nagaev <vladislav.nagaew@gmail.com>"

ENV \ 
    # Задание версий сервисов
    SPARK_VERSION=3.3.1 \
    HADOOP_FOR_SPARK_VERSION=without-hadoop

ENV \
    # Задание домашних директорий
    SPARK_HOME=${APPS_HOME}/spark \
    PYSPARK_PYTHON=/usr/bin/python3 \
    # Полные наименования сервисов
    SPARK_NAME=spark-${SPARK_VERSION}-bin-${HADOOP_FOR_SPARK_VERSION}

ENV \
    # Директории конфигураций
    HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_HOME}/lib/native \
    HADOOP_OPTS="-Djava.library.path=${HADOOP_HOME}/lib/native" \
    JAVA_LIBRARY_PATH=${HADOOP_HOME}/lib/native:${JAVA_LIBRARY_PATH} \
    LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH} \
    SPARK_CONF_DIR=${SPARK_HOME}/conf \
    SPARK_DIST_CLASSPATH="${HADOOP_CONF_DIR}\
:${HADOOP_HOME}/share/hadoop/tools/lib/*\
:${HADOOP_HOME}/share/hadoop/common/lib/*\
:${HADOOP_HOME}/share/hadoop/common/*\
:${HADOOP_HOME}/share/hadoop/hdfs\
:${HADOOP_HOME}/share/hadoop/hdfs/lib/*\
:${HADOOP_HOME}/share/hadoop/hdfs/*\
:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*\
:${HADOOP_HOME}/share/hadoop/mapreduce/*\
:${HADOOP_HOME}/share/hadoop/yarn\
:${HADOOP_HOME}/share/hadoop/yarn/lib/*\
:${HADOOP_HOME}/share/hadoop/yarn/*" \
    # URL-адреса для скачивания
    SPARK_URL=https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_NAME}.tgz \
    # Обновление переменных путей
    PATH=${PATH}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin \
    PYTHONPATH=${PYTHONPATH}:${SPARK_HOME}/python


RUN \
    # --------------------------------------------------------------------------
    # Установка Apache Spark
    # --------------------------------------------------------------------------
    # Скачивание GPG-ключа
    curl --remote-name --location https://downloads.apache.org/spark/KEYS && \
    # Установка gpg-ключа
    gpg --import KEYS && \
    # Скачивание архива Apache Spark
    curl --fail --show-error --location ${SPARK_URL} --output /tmp/${SPARK_NAME}.tgz && \
    # Скачивание PGP-ключа
    curl --fail --show-error --location ${SPARK_URL}.asc --output /tmp/${SPARK_NAME}.tgz.asc && \
    # Верификация ключа шифрования
    gpg --verify /tmp/${SPARK_NAME}.tgz.asc && \
    # Распаковка архива Apache Spark в рабочую папку
    tar -xf /tmp/${SPARK_NAME}.tgz -C ${APPS_HOME}/ && \
    # Удаление исходного архива и ключа шифрования
    rm /tmp/${SPARK_NAME}.tgz* && \
    # Создание символической ссылки на Apache Spark
    ln -s ${APPS_HOME}/${SPARK_NAME} ${SPARK_HOME} && \
    # Создание файла конфигурации
    touch ${SPARK_CONF_DIR}/spark-defaults.conf && \
    # Рабочая директория Apache Spark
    mkdir -p ${SPARK_HOME}/work && \
    mkdir -p ${SPARK_HOME}/logs && \
    chown -R ${USER}:${GID} ${SPARK_HOME} && \
    chmod -R a+rwx ${SPARK_HOME}
    # --------------------------------------------------------------------------

# Копирование файлов проекта
COPY ./entrypoint/* /entrypoint/

# Точка входа
ENTRYPOINT ["/bin/bash", "/entrypoint/spark-entrypoint.sh"]
CMD []
