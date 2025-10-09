Kafka:-

sudo apt update
sudo apt install openjdk-17-jdk -y
java -version

Download Apache Kafka:-

sudo wget https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz

or direct go to web
https://kafka.apache.org/downloads  (using 2.13.0) this is lts version

sudo tar -xvzf kafka_2.13-3.7.0.tgz
sudo mv kafka_2.13-3.7.0 kafka
sudo chown -R $USER:$USER kafka

Start Zookeeper and Kafka (Manually):-

cd /Download/kafka
bin/zookeeper-server-start.sh config/zookeeper.properties

cd /Download/kafka
bin/kafka-server-start.sh config/server.properties


Create a new Topic:-
bin/kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
bin/kafka-topics.sh --list --bootstrap-server localhost:9092


Produce message:-
bin/kafka-console-producer.sh --topic test-topic --bootstrap-server localhost:9092


Consume Message :-
bin/kafka-console-consumer.sh --topic test-topic --from-beginning --bootstrap-server localhost:9092
============================================================================================================================================================
zookeeper-server-start.bat ..\..\config\zookeeper.properties

kafka-server-start.bat ..\..\config\server.properties

kafka-topics.bat --create --topic my-topic --bootstrap-server localhost:9092 --replication-factor 1 --partitions 3

kafka-console-producer.bat --broker-list localhost:9092 --topic my-topic

kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic my-topic --from-beginning

🟢 SENDING MESSAGES COMMANDS

zookeeper-server-start.bat ..\..\config\zookeeper.properties

kafka-server-start.bat ..\..\config\server.properties

kafka-topics.bat --create --topic foods --bootstrap-server localhost:9092 --replication-factor 1 --partitions 4

kafka-console-producer.bat --broker-list localhost:9092 --topic foods --property "key.separator=-" --property "parse.key=true"

kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic foods --from-beginning -property "key.separator=-" --property "print.key=false"	

