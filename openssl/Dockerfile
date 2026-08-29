FROM debian:bookworm-slim

WORKDIR /build

ARG PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends curl perl build-essential ca-certificates zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ARG OPENSSL_VERSION

RUN echo "Building OpenSSL ${OPENSSL_VERSION}" \
    && curl -fsSL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" | tar xz -C /tmp \
    && cd "/tmp/openssl-${OPENSSL_VERSION}" \
    && ./config --prefix=/usr/local --openssldir=/usr/local/etc/ssl --libdir=lib no-tests shared enable-ktls enable-fips zlib \
    && make -j"$(nproc)" \
    && make install_sw install_ssldirs install_fips \
    && rm -rf /tmp/openssl-*

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openssl.conf && ldconfig
