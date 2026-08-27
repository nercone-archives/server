#!/bin/sh
set -e

envsubst '${MAIL_DB_PASSWORD}' < /etc/dovecot.d/dovecot.conf > /etc/dovecot/dovecot.conf
chmod 640 /etc/dovecot/dovecot.conf

rm -rf /etc/dovecot/sieve
cp -a /etc/dovecot-sieve /etc/dovecot/sieve

sievec /etc/dovecot/sieve/default.sieve

chown -R vmail:vmail /etc/dovecot/sieve

chown vmail:vmail /srv/vmail

exec dovecot -F
