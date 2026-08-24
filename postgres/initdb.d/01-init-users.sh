#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER gitea WITH PASSWORD '${GITEA_DB_PASSWORD}';
    CREATE DATABASE gitea OWNER gitea;
EOSQL
