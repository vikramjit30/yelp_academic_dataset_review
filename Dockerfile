FROM java:8 

RUN apt-get update
RUN apt-get install -y maven

RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0-bin-hadoop2.7.tgz

RUN tar -xzf spark-2.0.0-bin-hadoop2.7.tgz

RUN mv spark-2.0.0-bin-hadoop2.7 /opt/spark