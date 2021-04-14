#! /bin/bash

certname=$1
password=codingharbour

# Create a keystore
keytool -genkeypair \
  -alias $certname \
  -keyalg RSA \
  -keysize 2048 \
  -validity 365 \
  -keystore $certname.keystore.jks \
  -dname "CN=$certname,OU=TEST,O=CodingHarbour,L=Oslo,C=NO" \
  -ext "SAN=dns:$certname,dns:localhost" \
  -storepass $password \
  -keypass $password \
  -storetype pkcs12

# create a CSR
keytool -certreq \
  -sigAlg SHA256withRSA \
  -alias $certname \
  -file $certname.csr \
  -keystore $certname.keystore.jks \
  -ext "SAN=dns:$certname,dns:localhost" \
  -storepass $password \
  -keypass $password \


# Sign the CSR with the root CA
openssl x509 -req \
  -CA root.crt \
  -CAkey root.key \
  -in $certname.csr \
  -out $certname-signed.crt \
  -sha256 \
  -days 365 \
  -CAcreateserial \
  -passin pass:$password \
  -extensions v3_req \
  -extfile <(cat <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
CN = $certname
[v3_req]
subjectAltName = @alt_names
[alt_names]
DNS.1 = $certname
DNS.2 = localhost
EOF
)

# import the root CA into the keystore
keytool -import \
  -noprompt \
  -keystore $certname.keystore.jks \
  -alias root-ca \
  -file root.crt \
  -storepass $password \
  -keypass $password

# import signed cert into the keystore
keytool -import \
  -noprompt \
  -keystore $certname.keystore.jks \
  -alias $certname \
  -file $certname-signed.crt \
  -storepass $password \
  -keypass $password \
  -ext "SAN=dns:$certname,dns:localhost"
