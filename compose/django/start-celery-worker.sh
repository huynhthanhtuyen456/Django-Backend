#!/bin/bash

cd /app
celery -A app.core worker -P eventlet -c 100
