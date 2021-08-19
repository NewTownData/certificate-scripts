#!/usr/bin/env bash
SERIAL_ID=1

CA_FILE_NAME_PREFIX=example_ca
CERTIFICATE_NAME=www_example_com

KEY_BIT_COUNT=4096
EXPIRATION_IN_DAYS=365

echo "Using CA file name prefix ${CA_FILE_NAME_PREFIX}"

cat << EOT > .tmp_conf_csr.cnf
[ req ]
default_bits = $KEY_BIT_COUNT
distinguished_name = req_distinguished_name
req_extensions = v3_server
prompt      = no
string_mask = utf8only
utf8        = yes
copy_extensions = copy

[ req_distinguished_name ]
# country (2 letter code)
C=GB

# State or Province Name (full name)
ST=London

# Locality Name (eg. city)
L=London

# Organization (eg. company)
O=Example

# Organizational Unit Name (eg. section)
OU=Server

# Common Name (*.example.com is also possible)
CN=www.example.com

# E-mail contact
emailAddress=postmaster@example.com

[ alt_server ]
DNS.1 = www.example.com
DNS.2 = example.com
IP.1 = 192.168.0.2
IP.2 = 192.168.0.3

[ v3_server ]
basicConstraints            = critical, CA:FALSE
subjectKeyIdentifier        = hash
keyUsage                    = critical, digitalSignature
extendedKeyUsage            = critical, serverAuth
subjectAltName              = @alt_server
EOT

cat << EOT > .tmp_conf.cnf
[ ca ]
default_ca                      = CA_default

[ CA_default ]
certificate                     = "$CA_FILE_NAME_PREFIX.crt"
private_key                     = "$CA_FILE_NAME_PREFIX.key"
copy_extensions                 = copy

`cat .tmp_conf_csr.cnf`
authorityKeyIdentifier      = keyid:always, issuer:always
EOT

openssl genrsa -out ${CERTIFICATE_NAME}.key $KEY_BIT_COUNT
openssl req -new -config .tmp_conf_csr.cnf -out ${CERTIFICATE_NAME}.csr -key ${CERTIFICATE_NAME}.key
openssl req -noout -text -in ${CERTIFICATE_NAME}.csr

openssl x509 -req -extfile .tmp_conf.cnf -sha256 -days $EXPIRATION_IN_DAYS -in ${CERTIFICATE_NAME}.csr \
  -CA $CA_FILE_NAME_PREFIX.crt -CAkey $CA_FILE_NAME_PREFIX.key -set_serial $SERIAL_ID \
  -out ${CERTIFICATE_NAME}.crt -extensions v3_server
openssl x509 -text -in ${CERTIFICATE_NAME}.crt

echo "Serial ID: $SERIAL_ID" > ${CERTIFICATE_NAME}.serial_id.txt

rm -f .tmp_conf.cnf
rm -f .tmp_conf_csr.cnf
rm -f "${CERTIFICATE_NAME}.csr"

echo "All Done (${CERTIFICATE_NAME})"
