# Spark Docker

Spark Docker image built on top of [hadoop-base:3.3.4](https://github.com/VladislavNagaev/Hadoop-Docker.git)

## Quick Start

Build image:
~~~
make --file Makefile 
~~~

Depoyment of containers:
~~~
docker-compose -f docker-compose.yaml up -d
~~~


## Interfaces:
---
* [Spark-Master WebUi](http://127.0.0.1:8090/)


## Technologies
---
Project is created with:
* Apache Hadoop version: 3.3.4
* Apache Spark version: 3.3.1
* Docker verion: 20.10.22
* Docker-compose version: v2.11.1

