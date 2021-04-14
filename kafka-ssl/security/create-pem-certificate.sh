#! /bin/bash

certname=$1
password=codingharbour

# create a CSR
openssl req \
  -newkey rsa:2048 \
  -nodes \
  -keyout $certname.key \
  -out $certname.csr \
  -subj "/CN=$certname/OU=TEST/O=CodingHarbour/L=Oslo/C=NO"

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
#   -extensions v3_req \
#   -extfile <(cat <<EOF
# [req]
# distinguished_name = req_distinguished_name
# x509_extensions = v3_req
# prompt = no
# [req_distinguished_name]
# CN = $certname
# [v3_req]
# subjectAltName = @alt_names
# [alt_names]
# DNS.1 = $certname
# DNS.2 = localhost
# EOF
# )
