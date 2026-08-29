#!/bin/sh
set -e

envsubst '${MAIL_DB_PASSWORD}' < /etc/dovecot.d/dovecot.conf > /etc/dovecot/dovecot.conf
chmod 640 /etc/dovecot/dovecot.conf

mkdir -p /etc/dovecot/tls
cp /etc/dovecot-tls/ca.pem /etc/dovecot-tls/cert.pem /etc/dovecot-tls/key.pem /etc/dovecot/tls/
chmod 640 /etc/dovecot/tls/key.pem

printf 'Password: %s\n' "${RSPAMD_PASSWORD}" > /etc/dovecot/rspamd-password
chmod 640 /etc/dovecot/rspamd-password
chown vmail:vmail /etc/dovecot/rspamd-password

rm -rf /etc/dovecot/sieve
cp -a /etc/dovecot-sieve /etc/dovecot/sieve

sievec /etc/dovecot/sieve/default.sieve

chown -R vmail:vmail /etc/dovecot/sieve

chown vmail:vmail /srv/vmail

exec dovecot -F
