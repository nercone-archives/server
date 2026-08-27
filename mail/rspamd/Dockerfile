FROM debian:trixie-slim

ARG TRIXIE_PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends rspamd gettext-base ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 11332 11333 11334

STOPSIGNAL SIGTERM

CMD ["/usr/local/bin/entrypoint.sh"]
