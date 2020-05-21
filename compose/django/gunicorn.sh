#!/bin/sh

python /app/manage.py collectstatic --noinput
gunicorn config.wsgi -b 0.0.0.0:8000 --chdir=/app
