#!/bin/sh

#install dependencies
add-apt-repository ppa:jonathonf/python-3.6
apt-get update -y
apt-get install supervisor python3-pip systemd python3.6 -y
apt update -New_York
apt install git-all tzdata -y
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

# alias and use python3
alias python=python3

# check out git repo if not local development

# setup project folder
pip3 install virtualenv
mkdir /root/project/api -p
cd /root/project/api
virtualenv venv
source venv/bin/activate
pip3 install -r requirements/requirements.txt
# set variables in .env: BASE_URL, DATABASE_URL, CELERY_BROKER_URL, EMAIL_BACKEND, SENDGRID_API_KEY
mkdir ./config/settings/ -p
cp .env config/settings/.env
ls -l
python ./manage.py migrate

# start supervisord
service supervisor restart