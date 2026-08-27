#!/usr/bin/env bash
set -e

sudo git pull

docker compose exec proxy nginx -t
docker compose exec proxy nginx -s reload

docker compose restart mail-postfix mail-dovecot mail-rspamd mail-roundcube
