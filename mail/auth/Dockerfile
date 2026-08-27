FROM python:3-slim

WORKDIR /srv

COPY auth.py /srv/auth.py

USER nobody

EXPOSE 10080

STOPSIGNAL SIGTERM

CMD ["python3", "-u", "/srv/auth.py"]
