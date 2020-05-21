#!/bin/sh
export DATABASE_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}"

python ./manage.py migrate
python manage.py runserver 0.0.0.0:8000

