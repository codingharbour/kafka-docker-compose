#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $DIR && rm root.crt root.key consumer.properties producer.properties credentials truststore.jks

for i in broker zookeeper
do
    rm $i-signed.crt $i.csr $i.keystore.jks
done

for i in producer consumer
do
    rm $i-signed.crt $i.key $i.csr
done
