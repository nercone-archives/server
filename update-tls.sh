#!/usr/bin/env bash
set -e

TLS_DIR="$(cd "$(dirname "$0")" && pwd)/tls"

echo
echo "> Version Check"

OPENSSL_VERSION=$(curl -fsSL "https://api.github.com/repos/openssl/openssl/releases?per_page=100" \
    | grep -o '"tag_name": *"openssl-[^"]*"' \
    | sed 's/.*openssl-\([^"]*\)".*/\1/' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V \
    | tail -1)

echo "OpenSSL ${OPENSSL_VERSION} (openssl-${OPENSSL_VERSION})"

echo
echo "> Build OpenSSL"

docker build -t "nercone-openssl:${OPENSSL_VERSION}" --build-arg OPENSSL_VERSION="${OPENSSL_VERSION}" ./openssl

echo
echo "> Prepare"

mkdir -p "${TLS_DIR}/ca" "${TLS_DIR}/postgres" "${TLS_DIR}/dovecot" "${TLS_DIR}/postfix" "${TLS_DIR}/roundcube" "${TLS_DIR}/auth"

echo
echo "> Generate Internal CA"

if [ ! -f "${TLS_DIR}/ca/ca.pem" ]; then
    docker run --rm -v "${TLS_DIR}:/tls" "nercone-openssl:${OPENSSL_VERSION}" /usr/local/bin/openssl req \
        -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-384 -sha384 -nodes -days 7300 \
        -subj "/CN=nercone internal CA" \
        -addext "basicConstraints=critical,CA:TRUE" \
        -addext "keyUsage=critical,keyCertSign,cRLSign" \
        -keyout /tls/ca/ca.key -out /tls/ca/ca.pem
    sudo chmod 600 "${TLS_DIR}/ca/ca.key"
    echo "Internal CA generated: ${TLS_DIR}/ca/ca.pem"
fi

echo
echo "> Generate Service Certificate"

for SERVICE in postgres dovecot postfix; do
    if [ ! -f "${TLS_DIR}/${SERVICE}/cert.pem" ]; then
        docker run --rm -v "${TLS_DIR}:/tls" "nercone-openssl:${OPENSSL_VERSION}" /usr/local/bin/openssl req \
            -newkey ec -pkeyopt ec_paramgen_curve:P-384 -sha384 -nodes \
            -subj "/CN=${SERVICE}" \
            -addext "subjectAltName=DNS:${SERVICE}" \
            -addext "keyUsage=critical,digitalSignature" \
            -addext "extendedKeyUsage=serverAuth" \
            -keyout "/tls/${SERVICE}/key.pem" -out "/tls/${SERVICE}/csr.pem"
        docker run --rm -v "${TLS_DIR}:/tls" "nercone-openssl:${OPENSSL_VERSION}" /usr/local/bin/openssl x509 \
            -req -in "/tls/${SERVICE}/csr.pem" \
            -CA /tls/ca/ca.pem -CAkey /tls/ca/ca.key -CAcreateserial \
            -days 3650 -sha384 -copy_extensions copy \
            -out "/tls/${SERVICE}/cert.pem"
        sudo rm "${TLS_DIR}/${SERVICE}/csr.pem"
        sudo chmod 600 "${TLS_DIR}/${SERVICE}/key.pem"
        echo "Certificate generated: ${TLS_DIR}/${SERVICE}/cert.pem"
    fi
done

echo
echo "> Finalize"

sudo chown 70:70 "${TLS_DIR}/postgres/key.pem"

sudo cp "${TLS_DIR}/ca/ca.pem" "${TLS_DIR}/dovecot/ca.pem"
sudo cp "${TLS_DIR}/ca/ca.pem" "${TLS_DIR}/postfix/ca.pem"
sudo cp "${TLS_DIR}/ca/ca.pem" "${TLS_DIR}/roundcube/ca.pem"
sudo cp "${TLS_DIR}/ca/ca.pem" "${TLS_DIR}/auth/ca.pem"
