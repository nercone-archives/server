#!/bin/sh
set -e

cp /etc/postfix.d/main.cf       /etc/postfix/main.cf
cp /etc/postfix.d/master.cf     /etc/postfix/master.cf
cp /etc/postfix.d/header_checks /etc/postfix/header_checks

mkdir -p /etc/postfix/pgsql
for template in /etc/postfix.d/pgsql/*.cf; do
    rendered="/etc/postfix/pgsql/$(basename "${template}")"
    envsubst '${MAIL_DB_PASSWORD}' < "${template}" > "${rendered}"
    chown root:postfix "${rendered}"
    chmod 640 "${rendered}"
done

mkdir -p /etc/postfix/tls
cp /etc/letsencrypt/live/nercone.dev/fullchain.pem /etc/postfix/tls/fullchain.pem
cp /etc/letsencrypt/live/nercone.dev/privkey.pem   /etc/postfix/tls/privkey.pem
chown root:postfix /etc/postfix/tls/fullchain.pem /etc/postfix/tls/privkey.pem
chmod 640 /etc/postfix/tls/fullchain.pem /etc/postfix/tls/privkey.pem

postfix check

exec postfix start-fg
