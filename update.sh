#!/usr/bin/env bash
set -e

echo "> Pull"

sudo git pull

echo
echo "> Version Check"

NGINX_VERSION=$(curl -fsSL "https://nginx.org/en/download.html" \
    | grep -oE 'nginx-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
    | sort -V \
    | tail -1)
echo "Nginx ${NGINX_VERSION}"

OPENSSL_VERSIONS=$(curl -fsSL "https://api.github.com/repos/openssl/openssl/releases?per_page=100" \
    | grep -o '"tag_name": *"openssl-[^"]*"' \
    | sed 's/.*openssl-\([^"]*\)".*/\1/' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V)

OPENSSL_VERSION=$(echo "${OPENSSL_VERSIONS}" | tail -1)
echo "OpenSSL ${OPENSSL_VERSION} (openssl-${OPENSSL_VERSION})"

OPENSSL3_VERSION=$(echo "${OPENSSL_VERSIONS}" | grep -E '^3\.' | tail -1)
echo "OpenSSL ${OPENSSL3_VERSION} (openssl-${OPENSSL3_VERSION})"

ROUNDCUBE_VERSION=$(curl -fsSL "https://api.github.com/repos/roundcube/roundcubemail/releases?per_page=100" \
    | grep -o '"tag_name": *"[^"]*"' \
    | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V \
    | tail -1)
echo "Roundcube ${ROUNDCUBE_VERSION}"

packages_version() {
    local SUITE="$1"
    local MAIN_RELEASE MAIN_HASH SECURITY_RELEASE SECURITY_HASH
    MAIN_RELEASE=$(curl -fsSL "http://deb.debian.org/debian/dists/${SUITE}/Release")
    MAIN_HASH=$(echo "${MAIN_RELEASE}" | awk '/^SHA256:/{in_sha=1; next} in_sha && / main\/binary-amd64\/Packages$/{print $1; exit}')
    SECURITY_RELEASE=$(curl -fsSL "https://security.debian.org/debian-security/dists/${SUITE}-security/Release")
    SECURITY_HASH=$(echo "${SECURITY_RELEASE}" | awk '/^SHA256:/{in_sha=1; next} in_sha && / main\/binary-amd64\/Packages$/{print $1; exit}')
    echo "${MAIN_HASH:0:16}-${SECURITY_HASH:0:16}"
}

PACKAGES_VERSION=$(packages_version bookworm)
echo "Packages (bookworm) ${PACKAGES_VERSION}"

TRIXIE_PACKAGES_VERSION=$(packages_version trixie)
echo "Packages (trixie)   ${TRIXIE_PACKAGES_VERSION}"

echo
echo "> Build OpenSSL"

docker build -t "nercone-openssl:${OPENSSL_VERSION}" \
    --build-arg PACKAGES_VERSION="${PACKAGES_VERSION}" \
    --build-arg OPENSSL_VERSION="${OPENSSL_VERSION}" \
    ./openssl

docker build -t "nercone-openssl:${OPENSSL3_VERSION}" \
    --build-arg PACKAGES_VERSION="${PACKAGES_VERSION}" \
    --build-arg OPENSSL_VERSION="${OPENSSL3_VERSION}" \
    ./openssl

echo
echo "> Build"

docker compose build \
    --build-arg PACKAGES_VERSION="${PACKAGES_VERSION}" \
    --build-arg TRIXIE_PACKAGES_VERSION="${TRIXIE_PACKAGES_VERSION}" \
    --build-arg NGINX_VERSION="${NGINX_VERSION}" \
    --build-arg OPENSSL_IMAGE="nercone-openssl:${OPENSSL_VERSION}" \
    --build-arg OPENSSL3_IMAGE="nercone-openssl:${OPENSSL3_VERSION}" \
    --build-arg ROUNDCUBE_VERSION="${ROUNDCUBE_VERSION}"

echo
echo "> Start"

docker compose up -d

echo
echo "> Reload"

docker compose exec proxy nginx -t
docker compose exec proxy nginx -s reload

docker compose kill -s HUP onion

docker compose restart mail-postfix mail-dovecot mail-rspamd mail-roundcube
