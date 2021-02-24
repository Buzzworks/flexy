#!/usr/bin/bash
sleep 2

#Script Would
OUTPUT=$(/opt/flexydial/ssl.sh)

status=$?

printf "SSL Script exited with exit code : '$status' \n"
printf "SSL Script Output: \n $OUTPUT \n"

if test $status -eq 0
then

if [ ! -d "/etc/freeswitch/tls" ]; then
        printf "Creating freeswitch TLS directory...\n"
        mkdir -p "/etc/freeswitch/tls"
        chown freeswitch.daemon /etc/freeswitch -R
else
        printf "Freeswitch TLS Directory already exists..\n"
fi
cat /etc/pki/tls/certs/localhost.crt /etc/pki/tls/private/localhost.key > /etc/freeswitch/tls/wss.pem
cat /etc/pki/tls/certs/localhost.crt /etc/pki/tls/private/localhost.key > /etc/freeswitch/tls/agent.pem
cat /etc/pki/CA/certs/buzzworks-ca.crt > /etc/freeswitch/tls/cafile.pem
rm -rf /etc/freeswitch/tls/dtls-srtp.pem
rm -rf /var/lib/freeswitch/db/
printf "Certificate generated for freeswitch..\n"
systemctl restart httpd
systemctl restart freeswitch
systemctl restart flexydial-fs-dialplan
else
printf "No Need regeneration of certificate..\n"
fi


