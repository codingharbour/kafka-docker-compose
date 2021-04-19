#! /bin/bash

certname=$1
password=codingharbour

# generate encrypted private key
# openssl genrsa \
#   -aes256 \
#   -passout pass:$password \
#   -out $certname.key \
#   3072

openssl req -newkey \
  rsa:2048 \
  -keyout $certname.key \
  -out $certname.csr \
  -passin pass:$password \
  -passout pass:$password \
  -subj "/CN=$certname/OU=TEST/O=CodingHarbour/L=Oslo/C=NO"

#convert the key to PKCS8, otherwise kafka cannot read it
openssl pkcs8 \
  -topk8 \
  -in $certname.key \
  -inform pem \
  -out $certname-pkcs8.key \
  -outform pem \
  -passin pass:$password \
  -passout pass:$password

mv $certname-pkcs8.key $certname.key

# create a CSR
# openssl req \
#   -key $certname-pkcs8.key \
#   -out $certname.csr \
#   -subj "/CN=$certname/OU=TEST/O=CodingHarbour/L=Oslo/C=NO" \
#   -passin pass:$password \
#   -passout pass:$password

# Sign the CSR with the root CA
openssl x509 -req \
  -CA root.crt \
  -CAkey root.key \
  -in $certname.csr \
  -out $certname-signed.crt \
  -sha256 \
  -days 365 \
  -CAcreateserial \
  -passin pass:$password
