## Yelp Dataset Challenge

### Introduction

This application uploads yelp_academic_dataset_review dataset into HDFS for analytics and create spark dataframe to query the data.

<b>yelp-data-upload-to-HDFS.sh</b> script will take dataset tar file as parameter and upload extracted json files to HDFS

Another very interesting use-case, is to include web-based notebooks that enables faster interactive data-analytics than the Spark-shell like Zeppelin

### Architecture

Current Architecture Design:

HDFS => Spark => Cassandra => Visualization Tool

Proposed Future Architecture:

Yelp => Kafka => Spark Streaming => Cassandra/HDFS => Visualization Tools 

### SMACK Sandbox

Please refer to https://github.com/kartik-dev/SMACK-Sandbox for more information on SMACK-Sandbox

## Docker Images

kramalingam/spark - Dockerized spark binaries as base image for driver application to use

kramalingam/spark-zeppelin - Dockerized zeppelin for beautiful data-driven, interactive and collaborative documents with SQL, Scala

kramalingam/spark-driver - Dockerized spark driver application with 
 
## Installation

#### 1. Setup single node SMACK sandbox virtual machine

Clone SMACK vagrant repository

```
git clone https://github.com/kartik-dev/SMACK-Sandbox.git
```

Bring up SMACK single node VM

This might take some time (Approx 10 to 15mins),since it downloads and installs hadoop, mesos, spark, cassandra, nifi, confluent-io platform and Zeppelin

```
vagrant up
```

Once ready, ssh to smack vm (use putty)

```
ip: 192.168.0.50

username: root

password: vagrant
```

#### 2. Yelp Dataset challenge spark application souce code - Clone yelp_academic_dataset_review repository

```
cd /root

git clone https://github.com/kartik-dev/yelp_academic_dataset_review.git
```

Download yelp dataset from https://www.yelp.com/dataset_challenge/dataset

Upload dataset into HDFS with scripts/yelp-data-upload-to-HDFS.sh

```
cd yelp_academic_dataset_review

sh scripts/yelp-data-upload-to-HDFS.sh <tar file path>
```

#### 3. Dockerizing Spark - Build Spark Base docker Image

Downloads base java 8 image and installs spark 2.0 binaries.

```
docker build -t kramalingam/spark -f SparkBaseDockerImage .

or (pull the image from docker-io registry)

docker pull kramalingam/spark
```

#### 4. Dockerizing Spark Driver - Build docker image of Spark Driver Application

Note that this will take a while when you start it for the first time since it downloads and installs maven and downloads all the projectís dependencies. Every subsequent start of this build will only take a few seconds, as again everything will be already cached

The pom.xml contains a very basic Maven configuration. It configures the Spark 2.0 dependencies using a Java 1.8 compiler and creates a fat jar with all the dependencies.

sbt build tool could be used in place of maven. This could be easily be replaced in Dockerfile

```
cd /root/yelp_academic_dataset_review

mvn clean compile package

docker build -t kramalingam/spark-driver -f SparkDriverDockerImage .
```

#### 5. Bring up Cassandra
```
export PATH=$PATH:/usr/local/cassandra/bin

cp /vagrant/resources/cassandra/cassandra.yaml /usr/local/cassandra/conf/
 
cassandra -R &
```

open cqlsh

```
cqlsh 192.168.0.50 9042
```

#### 6. Submit Spark application
Once the image is built, submit spark application. Spark application will be deployed on standalone spark. This could be changed by changing the spark master URL

Setup docker network for spark driver

```
docker network create spark_network;
``` 
-- Count reviews by stars
 
```
docker run --net spark_network -e "SPARK_CLASS=com.demo.spark.YelpGroupReviewsByStars" kramalingam/spark-driver 
``` 

#### 7. Build and run spark-zeppelin container for adhoc analysis
```
docker build -t kramalingam/spark-zeppelin -f SparkZeppelinDockerImage .

or (pull the image from docker-io registry)

docker pull kramalingam/spark-zeppelin

docker run --rm -p 8080:8080 kramalingam/spark-zeppelin &
```

Zeppelin will be running at http://192.168.0.50:8080

## Things to improve
- [ ] Deploy spark on Mesos Cluster Manager with Marathon for better resource utilization and high availability 
- [ ] Deploy Spark driver application with Marathon for spark driver fault tolerance and high availability  
- [ ] Use of Dataflow tools like NiFi, StreamSets for enabling accelerated data collection, curation, analysis and delivery in real-time 
