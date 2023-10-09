#!/bin/bash
 
#----------------------------------------------------------------------------------------------------------------------------------
openssl req -x509 -sha256 -days 1825 -nodes -newkey rsa:2048 -subj "/CN=Example Certificate Authority" -keyout ca-key.pem -out ca.pem
 
#----------------------------------------------------------------------------------------------------------------------------------
create_cert() {
openssl genrsa -out $1-key.pem 2048
 
cat > $1_csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
 
[ dn ]
CN = $2
 
[ req_ext ]
subjectAltName = @alt_names
 
[ alt_names ]
DNS.1 = $3
EOF
 
openssl req -new -key $1-key.pem -out $1.csr -config $1_csr.conf
 
cat > $1_cert.conf <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
 
[ alt_names ]
DNS.1 = $3
EOF
 
openssl x509 -req -in $1.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out $1-cert.pem -days 1825 -sha256 -extfile $1_cert.conf
}
 
#----------------------------------------------------------------------------------------------------------------------------------
create_cert vaultlab-vault-0    "VAULT: vault"          "vault.example.com"
create_cert vaultlab-vault-1    "VAULT: vaultone"       "vault.example.com"
