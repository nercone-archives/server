#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER mail WITH PASSWORD '${MAIL_DB_PASSWORD}';
    CREATE DATABASE mail OWNER mail;
    CREATE USER roundcube WITH PASSWORD '${ROUNDCUBE_DB_PASSWORD}';
    CREATE DATABASE roundcube OWNER roundcube;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname mail <<-'EOSQL'
    CREATE TABLE domains (
        domain  TEXT    PRIMARY KEY,
        active  BOOLEAN NOT NULL DEFAULT TRUE
    );

    CREATE TABLE accounts (
        username     TEXT    NOT NULL,
        domain       TEXT    NOT NULL REFERENCES domains (domain) ON DELETE CASCADE,
        password     TEXT    NOT NULL,
        quota_bytes  BIGINT  NOT NULL DEFAULT 0,
        active       BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (username, domain)
    );

    CREATE TABLE aliases (
        source       TEXT    NOT NULL,
        destination  TEXT    NOT NULL,
        active       BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (source, destination)
    );

    CREATE INDEX aliases_source_idx ON aliases (source);

    ALTER TABLE domains  OWNER TO mail;
    ALTER TABLE accounts OWNER TO mail;
    ALTER TABLE aliases  OWNER TO mail;
EOSQL
