ARG OPENSSL_IMAGE

FROM ${OPENSSL_IMAGE} AS openssl-builder

FROM debian:bookworm-slim AS nginx-builder

WORKDIR /build

ARG PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends curl perl build-essential ca-certificates libpcre2-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=openssl-builder /usr/local/ /usr/local/

ARG NGINX_VERSION

RUN echo "Building Nginx ${NGINX_VERSION}" \
    && curl -fsSL "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar xz -C /tmp \
    && cd "/tmp/nginx-${NGINX_VERSION}" \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/run/nginx.pid \
        --http-client-body-temp-path=/var/cache/nginx/client_body \
        --http-proxy-temp-path=/var/cache/nginx/proxy \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi \
        --http-scgi-temp-path=/var/cache/nginx/scgi \
        --user=nginx \
        --group=nginx \
        --with-cc-opt="-I/usr/local/include -O2" \
        --with-ld-opt="-L/usr/local/lib -Wl,-rpath,/usr/local/lib" \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_v3_module \
        --with-http_realip_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-pcre \
        --with-pcre-jit \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/nginx-* \
    && ldd /usr/sbin/nginx \
        | awk 'NF==4 && $3~/^\// && $3!~/^\/usr\/local\// && $3!~/ld-linux/ && $3!~/libc\.so/ && $3!~/libdl\.so/ && $3!~/libpthread\.so/ && $3!~/libm\.so/ {print $3}' \
        | xargs -I{} cp {} /usr/local/lib/

FROM gcr.io/distroless/base-debian12 AS distroless

FROM debian:bookworm-slim AS setup

COPY --from=distroless /etc/passwd /etc/passwd
COPY --from=distroless /etc/group  /etc/group

ARG PACKAGES_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends libpcre2-8-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r nginx && useradd -r -g nginx -s /sbin/nologin -d /nonexistent nginx

RUN ldconfig

RUN mkdir -p /etc/nginx/conf.d /etc/nginx/stream.d /etc/nginx/mail.d /etc/nginx/snippets /var/cache/nginx /var/log/nginx /run/website /var/www/roundcube \
    && chown nginx:nginx /var/cache/nginx /var/log/nginx

FROM gcr.io/distroless/base-debian12

COPY --from=setup /etc/passwd        /etc/passwd
COPY --from=setup /etc/group         /etc/group
COPY --from=setup /etc/nginx         /etc/nginx
COPY --from=setup /var/cache/nginx   /var/cache/nginx
COPY --from=setup /var/log/nginx     /var/log/nginx
COPY --from=setup /var/www/roundcube /var/www/roundcube
COPY --from=setup /run/website       /run/website

COPY --from=nginx-builder /usr/local/lib/       /usr/local/lib/
COPY --from=nginx-builder /usr/local/etc/ssl    /usr/local/etc/ssl
COPY --from=nginx-builder /usr/sbin/nginx       /usr/sbin/nginx
COPY --from=nginx-builder /etc/nginx/mime.types /usr/local/share/nginx/mime.types

EXPOSE 25 80 143 443/tcp 443/udp 465 587 993

STOPSIGNAL SIGQUIT

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
