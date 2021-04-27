#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

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
    -keyout $root_key \
    -out $root_cert \
    -subj '/CN=root.codingharbourexample.com/OU=TEST/O=CodingHarbour/L=Oslo/C=NO' \
    -passin pass:$password \
    -passout pass:$password
fi

for i in producer consumer broker zookeeper
do
  echo "Create a certificate for $i"
  ./create-pem-certificate.sh $i
  echo
done

rm *.srl

echo "Create a truststore"

keytool -import \
  -noprompt \
  -keystore truststore.jks \
  -alias root-ca \
  -file $root_cert \
  -storepass $password \
  -keypass $password

# create properties for producer and consumer
consumer_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' consumer-signed.crt)
consumer_key=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' consumer.key)
truststore_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $root_cert)

echo
echo "Create consumer.properties with inline certificate, private key and truststore"
cat <<EOF > consumer.properties
security.protocol=SSL
ssl.keystore.type=PEM
ssl.keystore.certificate.chain=$consumer_cert
ssl.keystore.key=$consumer_key
ssl.key.password=$password
ssl.truststore.type=PEM
ssl.truststore.certificates=$truststore_cert
EOF

echo
echo "Create producer.properties that uses PEM files"
cat <<EOF > producer.properties
security.protocol=SSL
ssl.keystore.type=PEM
ssl.keystore.location=$DIR/producer-keypair.pem
ssl.key.password=$password
ssl.truststore.type=PEM
ssl.truststore.location=$DIR/$root_cert
EOF
