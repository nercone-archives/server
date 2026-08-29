#!/usr/bin/env bash
set -e

sudo git pull

OPENSSL3_VERSION=$(curl -fsSL "https://api.github.com/repos/openssl/openssl/releases?per_page=100" \
    | grep -o '"tag_name": *"openssl-[^"]*"' \
    | sed 's/.*openssl-\([^"]*\)".*/\1/' \
    | grep -E '^3\.[0-9]+\.[0-9]+$' \
    | sort -V \
    | tail -1)
echo "OpenSSL ${OPENSSL3_VERSION} (openssl-${OPENSSL3_VERSION})"

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
echo "Packages (trixie) ${TRIXIE_PACKAGES_VERSION}"

docker build -t "nercone-openssl:${OPENSSL3_VERSION}" \
    --build-arg PACKAGES_VERSION="${PACKAGES_VERSION}" \
    --build-arg OPENSSL_VERSION="${OPENSSL3_VERSION}" \
    ../openssl

docker compose build \
    --build-arg TRIXIE_PACKAGES_VERSION="${TRIXIE_PACKAGES_VERSION}" \
    --build-arg OPENSSL3_IMAGE="nercone-openssl:${OPENSSL3_VERSION}"

docker compose up -d
