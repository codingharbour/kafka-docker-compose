#!/bin/bash

root_cert=root.crt
root_key=root.key
password=codingharbour

echo $password > credentials

if [ ! -f "$root_cert" ]; then
    echo "Create a root certificate"
    openssl req \
    -x509 \
    -days 365 \
    -newkey rsa:2048 \
    -nodes \
    -keyout $root_key \
    -out $root_cert \
    -subj '/CN=root.codingharbourexample.com/OU=TEST/O=CodingHarbour/L=Oslo/C=NO' \
    -passin pass:$password \
    -passout pass:$password
fi

for i in broker zookeeper
do
  echo "Create a JKS certificate for $i"
  ./create-jks-certificate.sh $i
  echo
done


for i in producer consumer
do
  echo "Create a certificate for $i"
  ./create-pem-certificate.sh $i
  echo
done

echo "Create a truststore"

keytool -import \
  -noprompt \
  -keystore truststore.jks \
  -alias root-ca \
  -file $root_cert \
  -storepass $password \
  -keypass $password

# create properties for producer and consumer
CONSUMER_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' consumer-signed.crt)
CONSUMER_KEY=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' consumer.key)
TRUSTSTORE_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' root.crt)

echo
echo "Create consumer.properties"
cat <<EOF > consumer.properties
security.protocol=SSL
ssl.keystore.type=PEM
ssl.keystore.key.type=PEM
ssl.truststore.type=PEM
ssl.keystore.certificate.chain=$CONSUMER_CERT
ssl.keystore.key=$CONSUMER_KEY
ssl.truststore.certificates=$TRUSTSTORE_CERT
EOF

PRODUCER_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' producer-signed.crt)
PRODUCER_KEY=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' producer.key)


echo
echo "Create producer.properties"
cat <<EOF > producer.properties
security.protocol=SSL
ssl.keystore.type=PEM
ssl.keystore.key.type=PEM
ssl.truststore.type=PEM
ssl.keystore.certificate.chain=$PRODUCER_CERT
ssl.keystore.key=$PRODUCER_KEY
ssl.truststore.certificates=$TRUSTSTORE_CERT
EOF


rm *.srl
