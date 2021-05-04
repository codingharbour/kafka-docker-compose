# Kafka SSL example using PEM certificates

To start the cluster execute `./start-cluster.sh`

This will generate the root certificate as well as private keys and certificates for:
- broker
- producer
- consumer

It will also create a `producer.properties` and `consumer.properties` files to be used with `kafka-console-*` CLI tools.
