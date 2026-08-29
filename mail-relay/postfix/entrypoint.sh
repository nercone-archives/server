#!/bin/sh
set -e

if [ -z "${GCP_TAILNET_IP}" ]; then
    echo "GCP_TAILNET_IP is required (tailnet address of the GCP mail host)" >&2
    exit 1
fi

envsubst '${GCP_TAILNET_IP}' < /etc/postfix.d/main.cf > /etc/postfix/main.cf
cp /etc/postfix.d/master.cf   /etc/postfix/master.cf
cp /etc/postfix.d/openssl.cnf /etc/postfix/openssl.cnf

mkdir -p /var/lib/postfix-tls
if [ ! -f /var/lib/postfix-tls/cert.pem ]; then
    /usr/local/bin/openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-384 -sha384 -nodes -days 3650 \
        -subj "/CN=smtp.nercone.dev" -addext "subjectAltName=DNS:smtp.nercone.dev" \
        -keyout /var/lib/postfix-tls/key.pem -out /var/lib/postfix-tls/cert.pem
fi
chown root:postfix /var/lib/postfix-tls/cert.pem /var/lib/postfix-tls/key.pem
chmod 640 /var/lib/postfix-tls/cert.pem /var/lib/postfix-tls/key.pem

postfix check

exec postfix start-fg
