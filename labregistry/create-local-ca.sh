#!/bin/bash

set -e

CA_DIR=~/myCA
CN=${1:-"labregistry.local"}

echo "Creating local Certificate Authority in $CA_DIR"
mkdir -p $CA_DIR/{certs,crl,newcerts,private}
chmod 700 $CA_DIR/private
touch $CA_DIR/index.txt
echo 1000 > $CA_DIR/serial

cat > $CA_DIR/openssl.cnf <<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = $CA_DIR
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

private_key       = \$dir/private/ca.key.pem
certificate       = \$dir/certs/ca.cert.pem

default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 825
preserve          = no
policy            = policy_loose

[ policy_loose ]
commonName             = supplied
countryName            = optional
stateOrProvinceName    = optional
localityName           = optional
organizationName       = optional
organizationalUnitName = optional
emailAddress           = optional
EOF

# Generate CA private key and root certificate if not exists
if [ ! -f "$CA_DIR/private/ca.key.pem" ]; then
  echo "Generating CA private key..."
  openssl genrsa -out $CA_DIR/private/ca.key.pem 4096
  chmod 400 $CA_DIR/private/ca.key.pem

  echo "Creating CA root certificate..."
  openssl req -x509 -new -nodes -key $CA_DIR/private/ca.key.pem -sha256 -days 3650 \
    -out $CA_DIR/certs/ca.cert.pem -subj "/CN=MyHomeLab Root CA"
fi

# Generate key and CSR for service
echo "Generating certificate for $CN"
openssl genrsa -out $CN.key.pem 2048
openssl req -new -key $CN.key.pem -out $CN.csr.pem -subj "/CN=$CN"

# Sign the certificate
openssl ca -config $CA_DIR/openssl.cnf -in $CN.csr.pem -out $CN.cert.pem -batch -notext

echo
echo "Certificate created:"
echo "  Private key:  $(realpath $CN.key.pem)"
echo "  Certificate:  $(realpath $CN.cert.pem)"
echo "  CA Root Cert: $(realpath $CA_DIR/certs/ca.cert.pem)"
