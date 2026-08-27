FROM debian:trixie-slim

ARG TRIXIE_PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends postfix gettext-base ssl-cert ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -aG ssl-cert postfix

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 587

STOPSIGNAL SIGTERM

CMD ["/usr/local/bin/entrypoint.sh"]
