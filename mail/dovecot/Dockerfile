ARG OPENSSL3_IMAGE

FROM ${OPENSSL3_IMAGE} AS openssl

FROM debian:trixie-slim

ARG TRIXIE_PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        dovecot-core dovecot-imapd dovecot-lmtpd dovecot-sieve dovecot-managesieved dovecot-pgsql \
        gettext-base curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=openssl /usr/local/ /usr/local/

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openssl.conf && ldconfig \
    && rm -rf /usr/local/etc/ssl/certs \
    && ln -s /etc/ssl/certs /usr/local/etc/ssl/certs \
    && ln -s /etc/ssl/certs/ca-certificates.crt /usr/local/etc/ssl/cert.pem

RUN groupadd -g 5000 vmail && useradd -u 5000 -g vmail -s /usr/sbin/nologin -d /srv/vmail vmail \
    && mkdir -p /srv/vmail && chown vmail:vmail /srv/vmail

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 24 143 4190 12345

STOPSIGNAL SIGTERM

CMD ["/usr/local/bin/entrypoint.sh"]
