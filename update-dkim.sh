#!/usr/bin/env bash
set -e

ACTIVATE=false
if [ "${1:-}" = "--activate" ]; then
    ACTIVATE=true
    shift
fi

DOMAIN="${1:-nercone.dev}"
SELECTOR="${2:-$(date +%Y%m%d)}"

DKIM_DIR="$(cd "$(dirname "$0")" && pwd)/mail/data/rspamd/dkim"
KEY_NAME="${DOMAIN}.${SELECTOR}.key"
SELECTORS_MAP="${DKIM_DIR}/selectors.map"

echo "Domain: ${DOMAIN}"
echo "Selector: ${SELECTOR}"

if [ "${ACTIVATE}" = true ]; then
    if [ ! -f "${DKIM_DIR}/${KEY_NAME}" ]; then
        echo "Key not found: ${DKIM_DIR}/${KEY_NAME}" >&2
        exit 1
    fi

    sudo touch "${SELECTORS_MAP}"
    sudo sed -i "/^${DOMAIN}[[:space:]]/d" "${SELECTORS_MAP}"
    echo "${DOMAIN} ${SELECTOR}" | sudo tee -a "${SELECTORS_MAP}" > /dev/null
    echo "Selector activated: ${DOMAIN} -> ${SELECTOR}"

    docker compose exec mail-rspamd rspamadm configtest
    docker compose restart mail-rspamd

    echo
    echo "Verify the signature on the next outgoing message, then remove the old selector's TXT record after a few days."
    exit 0
fi

KEYGEN_OUTPUT=$(docker compose exec -T mail-rspamd \
    rspamadm dkim_keygen -b 3072 -s "${SELECTOR}" -d "${DOMAIN}" -k "/var/lib/rspamd/dkim/${KEY_NAME}")

docker compose exec -T mail-rspamd chown _rspamd:_rspamd "/var/lib/rspamd/dkim/${KEY_NAME}"
docker compose exec -T mail-rspamd chmod 600 "/var/lib/rspamd/dkim/${KEY_NAME}"
echo "DKIM key generated: ${DKIM_DIR}/${KEY_NAME}"

RECORD=$(echo "${KEYGEN_OUTPUT}" | grep -oE '"[^"]*"' | tr -d '"' | tr -d '\n')
echo
printf "%-40s TXT \"%s\"\n" "${SELECTOR}._domainkey.${DOMAIN}." "${RECORD}"
echo
echo "1. Publish the TXT record above."
echo "2. Wait for DNS propagation (at least 1 hour)."
echo "3. Run: ./update-dkim.sh --activate ${DOMAIN} ${SELECTOR}"
echo
echo "Switching the selector before the record propagates makes outgoing mail fail DKIM."
