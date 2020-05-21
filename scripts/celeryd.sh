#!/bin/bash

cd ~/app
./virtualenv/bin/celery -A app.core worker --autoscale=10,1 -P gevent -l ERROR --logfile="/var/log/celery-worker.log"
