
#!/bin/sh

#install dependencies
apt-get update -y
apt-get install nginx git-all tzdata -y
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

#remove apache2
update-rc.d -f apache2 remove