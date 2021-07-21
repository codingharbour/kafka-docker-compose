#! /bin/bash

certname=$1
password=codingharbour

openssl req -newkey \
  rsa:2048 \
  -keyout $certname.key \
  -out $certname.csr \
  -passin pass:$password \
  -passout pass:$password \
  -subj "/CN=$certname/OU=TEST/O=CodingHarbour/L=Oslo/C=NO"

#convert the key to PKCS8, otherwise kafka/java cannot read it
openssl pkcs8 \
  -topk8 \
  -in $certname.key \
  -inform pem \
  -v1 PBE-SHA1-RC4-128 \
  -out $certname-pkcs8.key \
  -outform pem \
  -passin pass:$password \
  -passout pass:$password

mv $certname-pkcs8.key $certname.key

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

# Combine private key and cert in one file
cat $certname.key $certname-signed.crt > $certname-keypair.pem
