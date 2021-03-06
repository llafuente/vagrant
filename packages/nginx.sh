#!/bin/sh

set -exuo pipefail

sudo yum install -y epel-release
sudo yum install -y nginx

sudo mkdir -p /etc/nginx/sites-available
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# curl 'https://raw.githubusercontent.com/llafuente/vagrant/master/nginx/nginx.conf'

sudo cp -f "${INSTALLER_PATH}/nginx/nginx.conf" /etc/nginx/nginx.conf

sudo systemctl start nginx
sudo systemctl enable nginx

# rotate logs, daily with date, compressed, delayed...
cat <<DELIM | sudo tee /etc/logrotate.d/nginx
/var/log/nginx/*log {
    create 0644 nginx nginx
    daily
    rotate 14
    notifempty
    dateext
    dateformat .%Y-%m-%d
    compress
    compresscmd /usr/bin/xz
    compressoptions -9
    compressext .xz
    delaycompress
    sharedscripts
    postrotate
        /bin/kill -USR1 `cat /run/nginx.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
DELIM

sudo cp -rf "${INSTALLER_PATH}/nginx/default.conf" /etc/nginx/sites-available/default.conf

sudo nginx -v

#result
RESULT=$(systemctl status nginx.service | grep 'Active: active (running)' | wc -l)
if [ "${RESULT}" == "1" ]
then
  echo "OK"
else
  echo "ERROR"
fi
