#!/bin/sh
set -e

if [ -z "${GCP_TAILNET_IP}" ]; then
    echo "GCP_TAILNET_IP is required (tailnet address of the GCP mail host)" >&2
    exit 1
fi

envsubst '${GCP_TAILNET_IP}' < /etc/postfix.d/main.cf > /etc/postfix/main.cf
cp /etc/postfix.d/master.cf /etc/postfix/master.cf

postfix check

exec postfix start-fg
