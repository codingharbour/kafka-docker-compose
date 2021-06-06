# Kafka SSL example using PEM certificates

> Read the whole tutorial: https://codingharbour.com/apache-kafka/using-pem-certificates-with-apache-kafka/

To start the cluster execute `./start-cluster.sh`

This will generate the root certificate as well as private keys and certificates for:
- broker
- zookeeper
- producer
- consumer

It will also create a `producer.properties` and `consumer.properties` files to be used with `kafka-console-*` CLI tools.
