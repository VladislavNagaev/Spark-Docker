# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 hadoop-base:3.3.4

LABEL maintainer="Vladislav Nagaev <vladislav.nagaew@gmail.com>"

# Изменение рабочего пользователя
USER root

# Выбор рабочей директории
WORKDIR /

ENV \ 
    # Задание версий сервисов
    SPARK_VERSION=3.3.1 \
    # Задание домашних директорий
    SPARK_HOME=/opt/spark

ENV \
    # Полные наименования сервисов
    SPARK_NAME=spark-${SPARK_VERSION} \
    # Директории конфигураций
    SPARK_CONF_DIR=${SPARK_HOME}/conf \
    # URL-адреса для скачивания
    SPARK_URL=https://github.com/apache/spark/archive/refs/tags/v${SPARK_VERSION}.tar.gz \
    # Обновление переменных путей
    PATH=${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}

RUN \
    # --------------------------------------------------------------------------
    # Подготовка shell-скриптов
    # --------------------------------------------------------------------------
    # Сборка Apache Spark
    echo \
'''#!/bin/bash \n\
SPARK_SOURCE_PATH="${1:-}" \n\
echo "Spark building started ..." \n\
owd="$(pwd)" \n\
cd ${SPARK_SOURCE_PATH} \n\
./build/mvn -Pscala-2.12 -Pyarn -Phive -Phive-thriftserver -Dhadoop.version=${HADOOP_VERSION} -DskipTests clean package \n\
cd "${owd}" \n\
echo "Spark building completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/spark-building.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/spark-building.sh && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Настройка прав доступа скопированных файлов/директорий
    # --------------------------------------------------------------------------
    # Директория/файл entrypoint
    chown -R ${USER}:${GID} ${ENTRYPOINT_DIRECTORY} && \
    chmod -R a+x ${ENTRYPOINT_DIRECTORY} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Apache Spark
    # --------------------------------------------------------------------------
    # Скачивание архива с исходным кодом Apache Spark из ветки master
    curl --fail --show-error --location ${SPARK_URL} --output /tmp/${SPARK_NAME}.tar.gz && \
    # Распаковка архива с исходным кодом Apache Spark в рабочую папку
    tar -xf /tmp/${SPARK_NAME}.tar.gz -C $(dirname ${SPARK_HOME})/ && \
    # Удаление исходного архива
    rm /tmp/${SPARK_NAME}.tar.gz* && \
    # Создание символической ссылки на Apache Spark
    ln -s $(dirname ${SPARK_HOME})/${SPARK_NAME} ${SPARK_HOME} && \
    # Сборка Apache Spark
    "${ENTRYPOINT_DIRECTORY}/spark-building.sh" ${SPARK_HOME} && \
    # Рабочая директория Apache Spark
    chown -R ${USER}:${GID} ${SPARK_HOME} && \
    chmod -R a+rwx ${SPARK_HOME} && \
    # Smoke test
    spark-submit --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Удаление неактуальных пакетов, директорий, очистка кэша
    # --------------------------------------------------------------------------
    rm --recursive  /root/.m2/repository && \
    apt --yes autoremove && \
    rm --recursive --force /var/lib/apt/lists/*
    # --------------------------------------------------------------------------

# Копирование файлов проекта
COPY ./entrypoint/* ${ENTRYPOINT_DIRECTORY}/

# Выбор рабочей директории
WORKDIR ${WORK_DIRECTORY}

# Точка входа
ENTRYPOINT ["/bin/bash", "/entrypoint/spark-entrypoint.sh"]
CMD []
