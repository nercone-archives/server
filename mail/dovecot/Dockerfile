FROM debian:trixie-slim

ARG TRIXIE_PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        dovecot-core dovecot-imapd dovecot-lmtpd dovecot-sieve dovecot-managesieved dovecot-pgsql \
        gettext-base curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 5000 vmail && useradd -u 5000 -g vmail -s /usr/sbin/nologin -d /srv/vmail vmail \
    && mkdir -p /srv/vmail && chown vmail:vmail /srv/vmail

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 24 143 4190 12345

STOPSIGNAL SIGTERM

CMD ["/usr/local/bin/entrypoint.sh"]
