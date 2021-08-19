#!/usr/bin/env bash
OUTPUT_FILE_PREFIX=example_
ORGANIZATION_NAME="Example"
EMAIL="postmaster@example.com"

KEY_BIT_COUNT=4096
EXPIRATION_IN_DAYS=3650

cat << EOT > .tmp_conf.cnf
[ req ]
default_bits = 4096
encrypt_key = yes
distinguished_name = req_distinguished_name
prompt = no
x509_extensions = v3_ca

[ req_distinguished_name ]
# country (2 letter code)
C=GB

# State or Province Name (full name)
ST=London

# Locality Name (eg. city)
L=London

# Organization (eg. company)
O=$ORGANIZATION_NAME

# Organizational Unit Name (eg. section)
OU=Server

# Common Name
CN=${ORGANIZATION_NAME} CA

# E-mail contact
emailAddress=$EMAIL

# The following values should prevent an accidental usage
# of this certificate by a server.
[ alt_ca_main ]
DNS.1 = Router.1
IP.1 = 127.0.0.1

[ v3_ca ]
basicConstraints            = critical, CA:TRUE
subjectKeyIdentifier        = hash
authorityKeyIdentifier      = keyid:always, issuer:always
subjectAltName              = @alt_ca_main
keyUsage                    = critical, cRLSign, digitalSignature, keyCertSign

EOT

CA_FILE="${OUTPUT_FILE_PREFIX}ca"

echo Creating Certificate Authority
openssl genrsa -out "${CA_FILE}.key" $KEY_BIT_COUNT
openssl req -new -sha256 -x509 -days $EXPIRATION_IN_DAYS -config .tmp_conf.cnf \
  -key "${CA_FILE}.key" -out "${CA_FILE}.crt"
openssl x509 -text -in "${CA_FILE}".crt

rm -f .tmp_conf.cnf

echo Done
