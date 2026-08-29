ARG OPENSSL3_IMAGE

FROM ${OPENSSL3_IMAGE} AS openssl

FROM debian:trixie-slim

ARG TRIXIE_PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        php8.4-fpm php8.4-pgsql php8.4-intl php8.4-mbstring php8.4-gd php8.4-zip \
        php8.4-xml php8.4-curl php8.4-ldap php8.4-bcmath \
        gnupg curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=openssl /usr/local/ /usr/local/

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openssl.conf && ldconfig \
    && rm -rf /usr/local/etc/ssl/certs \
    && ln -s /etc/ssl/certs /usr/local/etc/ssl/certs \
    && ln -s /etc/ssl/certs/ca-certificates.crt /usr/local/etc/ssl/cert.pem

ARG ROUNDCUBE_VERSION

RUN echo "Installing Roundcube ${ROUNDCUBE_VERSION}" \
    && curl -fsSL "https://github.com/roundcube/roundcubemail/releases/download/${ROUNDCUBE_VERSION}/roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz" \
        | tar xz -C /tmp \
    && mv "/tmp/roundcubemail-${ROUNDCUBE_VERSION}" /opt/roundcube \
    && rm -rf /opt/roundcube/installer /tmp/roundcubemail-*

RUN rm -f /etc/php/8.4/fpm/pool.d/www.conf \
    && sed -i 's#^error_log = .*#error_log = /proc/self/fd/2#' /etc/php/8.4/fpm/php-fpm.conf

COPY etc/php-fpm.conf /etc/php/8.4/fpm/pool.d/roundcube.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 9000

STOPSIGNAL SIGQUIT

CMD ["/usr/local/bin/entrypoint.sh"]
