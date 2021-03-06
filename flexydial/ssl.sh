#!/bin/sh
##
#############################################################################
# SSL Generation Script
# Version - 4.0
# Description : SSL generation with existing CA Certificate
#               by gathering current IP Address automatically.
#               So Make sure run this script only after IP Assigned.
#############################################################################

ip=$(ip route get 1 | sed 's/^.*src \([^ ]*\).*$/\1/;q')
PREVIP=$(awk -F "=" '/SERVERIP/ {print $2}' /opt/flexydial/buzzworks.conf)

if [ "$PREVIP" != "$ip" ]; then

if [ ! -z "$ip" ]; then
echo "Generating Certificate for IP : $ip"

cp /opt/flexydial/buzzworks-ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust
cp /opt/flexydial/buzzworks-ca.crt /etc/pki/CA/certs/
cp /opt/flexydial/buzzworks-ca.key /etc/pki/CA/private/

openssl genrsa -out /etc/pki/tls/private/localhost.key 4096

# Fill the necessary certificate data
CONFIG="/etc/pki/CA/certs/server-cert.conf"
cat >$CONFIG <<EOT
[ req ]
default_bits			= 4096
default_keyfile			= /etc/pki/tls/private/localhost.key
distinguished_name		= req_distinguished_name
string_mask			= nombstr
req_extensions			= v3_req
[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_default		= MY
countryName_min			= 2
countryName_max			= 2
stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Perak
localityName			= Locality Name (eg, city)
localityName_default		= Sitiawan
0.organizationName		= Organization Name (eg, company)
0.organizationName_default	= My Directory Sdn Bhd
organizationalUnitName		= Organizational Unit Name (eg, section)
organizationalUnitName_default	= Secure Web Server
commonName			= Common Name (eg, www.domain.com)
commonName_max			= 64
emailAddress			= Email Address
emailAddress_max		= 40
[ v3_req ]
nsCertType			= server
keyUsage 			= digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
basicConstraints		= CA:false
subjectKeyIdentifier		= hash
EOT

openssl req -new -config $CONFIG -key /etc/pki/tls/private/localhost.key -out /etc/pki/tls/certs/localhost.csr -subj "/C=IN/ST=Maharastra/L=Mumbai/O=Buzzworks Business Services Pvt Ltd/OU=Solutions Team/CN=${ip}/emailAddress=help@flexydial.com"

rm -f $CONFIG

if [ ! -f /etc/pki/tls/certs/localhost.csr ]; then
	exit 1
fi
# Check for root CA key
if [ ! -f /etc/pki/CA/private/buzzworks-ca.key -o ! -f /etc/pki/CA/certs/buzzworks-ca.crt ]; then
	exit 1
fi

if [ ! -d /etc/pki/CA/ca.db.certs ]; then
    mkdir /etc/pki/CA/ca.db.certs
fi

if [ ! -f /etc/pki/CA/ca.db.serial ]; then
    echo "01" >/etc/pki/CA/ca.db.serial
fi

if [ ! -f /etc/pki/CA/ca.db.index ]; then
    cp /dev/null /etc/pki/CA/ca.db.index
fi

#  create the CA requirement to sign the cert
cat >/etc/pki/CA/ca.config <<EOT
[ ca ]
default_ca              = default_CA
[ default_CA ]
dir                     = /etc/pki/CA
certs                   = \$dir
new_certs_dir           = \$dir/ca.db.certs
database                = \$dir/ca.db.index
serial                  = \$dir/ca.db.serial
certificate             = \$dir/certs/buzzworks-ca.crt
private_key             = \$dir/private/buzzworks-ca.key
default_days            = 3650
default_crl_days        = 30
default_md              = sha256
preserve                = no
x509_extensions		= server_cert
policy                  = policy_anything
[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
[ server_cert ]
basicConstraints	= CA:FALSE
subjectKeyIdentifier 	= hash
authorityKeyIdentifier	= keyid,issuer
keyUsage 		= digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName		= @subject_alt_names

[ subject_alt_names ]
DNS.1 			= buzzworks.com
DNS.2 			= flexydial.com
DNS.3 			= *.buzzworks.com
DNS.4 			= *.flexydial
DNS.5 			= *.local
DNS.6 			= *.localhost
DNS.7 			= *.localdomain
IP.1			= $ip
IP.2			= 127.0.0.1
IP.3			= ::1	
EOT

#  sign the certificate
openssl ca -batch -config /etc/pki/CA/ca.config -passin pass:flexydial -out /etc/pki/tls/certs/localhost.crt -infiles /etc/pki/tls/certs/localhost.csr  > /dev/null 2>&1


#  cleanup after SSLeay 
rm -f /etc/pki/CA/ca.config
rm -rf /etc/pki/CA/ca.db.*
#openssl verify -CAfile /etc/pki/CA/certs/buzzworks-ca.crt /etc/pki/tls/certs/localhost.crt
#openssl x509  -noout -text -in /etc/pki/tls/certs/localhost.crt
sed -i "s/\(^SERVERIP=\).*/\1$ip/" /opt/flexydial/buzzworks.conf
exit 0
fi
fi
exit 1
