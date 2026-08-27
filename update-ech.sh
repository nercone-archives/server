#!/usr/bin/env bash
set -e

PUBLIC_NAME="${1:-ech.nerc1.dev}"
MAX_NAME_LEN="${2:-40}"

ECH_DIR="$(cd "$(dirname "$0")" && pwd)/proxy/etc/ech"
PEM_FILE="${ECH_DIR}/${PUBLIC_NAME}.pem"

echo "Outer SNI: ${PUBLIC_NAME}"
echo "Padding: ${MAX_NAME_LEN}"

OPENSSL_VERSION=$(curl -fsSL "https://api.github.com/repos/openssl/openssl/releases?per_page=100" \
    | grep -o '"tag_name": *"openssl-[^"]*"' \
    | sed 's/.*openssl-\([^"]*\)".*/\1/' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V \
    | tail -1)

echo "OpenSSL ${OPENSSL_VERSION} (openssl-${OPENSSL_VERSION})"

docker build --target openssl-builder -t proxy-openssl-builder --build-arg OPENSSL_VERSION="${OPENSSL_VERSION}" .

docker run --rm -v "${ECH_DIR}:/ech" proxy-openssl-builder /usr/local/bin/openssl ech -public_name "${PUBLIC_NAME}" -max_name_len "${MAX_NAME_LEN}" -out "/ech/${PUBLIC_NAME}.pem"
chmod 600 "${PEM_FILE}"
echo "ECH key generated: ${PEM_FILE}"

ECHCONFIG=$(sudo awk '/-----BEGIN ECHCONFIG-----/{found=1; next} /-----END ECHCONFIG-----/{found=0} found' "${PEM_FILE}" | tr -d '\n')
for DOMAIN in \
    "nercone.dev." \
    "diamondgotcat.net." \
    "d-g-c.net." \
    "nerc1.dev."
do
    printf "%-28s HTTPS 1 . ech=%s\n" "${DOMAIN}" "${ECHCONFIG}"
done

docker compose exec proxy nginx -t
docker compose exec proxy nginx -s reload
