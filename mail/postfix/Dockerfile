ARG OPENSSL3_IMAGE

FROM ${OPENSSL3_IMAGE} AS openssl

FROM debian:trixie-slim

ARG TRIXIE_PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends postfix postfix-pgsql postfix-pcre gettext-base ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=openssl /usr/local/ /usr/local/

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openssl.conf && ldconfig \
    && rm -rf /usr/local/etc/ssl/certs \
    && ln -s /etc/ssl/certs /usr/local/etc/ssl/certs \
    && ln -s /etc/ssl/certs/ca-certificates.crt /usr/local/etc/ssl/cert.pem

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 25 10025

STOPSIGNAL SIGTERM

CMD ["/usr/local/bin/entrypoint.sh"]
