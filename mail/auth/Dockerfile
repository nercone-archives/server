# check=skip=InvalidDefaultArgInFrom

ARG OPENSSL3_IMAGE

FROM ${OPENSSL3_IMAGE} AS openssl

FROM python:3-slim

COPY --from=openssl /usr/local/ /usr/local/

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openssl.conf && ldconfig \
    && rm -rf /usr/local/etc/ssl/certs \
    && ln -s /etc/ssl/certs /usr/local/etc/ssl/certs \
    && ln -s /etc/ssl/certs/ca-certificates.crt /usr/local/etc/ssl/cert.pem

WORKDIR /srv

COPY auth.py /srv/auth.py

USER nobody

EXPOSE 10080

STOPSIGNAL SIGTERM

CMD ["python3", "-u", "/srv/auth.py"]
