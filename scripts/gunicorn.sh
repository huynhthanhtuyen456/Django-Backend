#!/bin/bash

cd ~/app
./virtualenv/bin/gunicorn config.wsgi -w 4 -b 0.0.0.0:8000
