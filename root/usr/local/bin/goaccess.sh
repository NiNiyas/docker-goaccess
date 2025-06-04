#!/bin/bash

set -e

mkdir -p /config/html
mkdir -p /config/data
mkdir -p /config/nginx
mkdir -p /config/nginx/logs
mkdir -p /opt/log

[ -f /config/goaccess.conf ] || cp /opt/goaccess.conf /config/goaccess.conf
[ -f /config/browsers.list ] || cp /opt/browsers.list /config/browsers.list

if [ ! -e "/opt/log/access.log" ]; then
    echo -e "\e[31m/opt/log/access.log does not exist. Exiting..\e[0m"
    exit 1
fi

echo -e '0 0 * * * /usr/sbin/logrotate -s /config/logrotate.status --force --verbose /etc/logrotate.conf\n' >> /tmp/cron

if [ -n "$MAXMIND_LICENSE_KEY" ]; then
  mkdir -p /config/geoip
  if [ ! -f "/config/geoip/GeoLite2-City.mmdb" ] || [ ! -f "/config/geoip/GeoLite2-ASN.mmdb" ]; then
    echo -e "\e[32mDownloading geoip databases.\e[0m"
    /etc/geoip.sh >> /config/geoip/geoip.log 2>&1
  fi
  if ! grep -q "geoip-database /config/geoip/GeoLite2-City.mmdb" /config/goaccess.conf; then
    echo "geoip-database /config/geoip/GeoLite2-City.mmdb" >> /config/goaccess.conf
    echo "geoip-database /config/geoip/GeoLite2-ASN.mmdb" >> /config/goaccess.conf
  fi
  echo -e '0 0 * * SUN /etc/geoip.sh >> /config/geoip/geoip.log 2>&1' >> /tmp/cron
  echo -e "\e[32mWeekly cron job to update geoip databases have been applied.\e[0m"
else
  if grep -q "geoip-database /config/geoip/GeoLite2-City.mmdb" /config/goaccess.conf; then
    grep -v "geoip-database /config/geoip/GeoLite2-City.mmdb" /config/goaccess.conf >/config/tmpfile && mv /config/tmpfile /config/goaccess.conf
    grep -v "geoip-database /config/geoip/GeoLite2-ASN.mmdb" /config/goaccess.conf >/config/tmpfile && mv /config/tmpfile /config/goaccess.conf
  fi
fi

nohup supercronic /tmp/cron >> /config/cron.log 2>&1 &
nginx -p /config/nginx -c /opt/nginx.conf &

run_args="--config-file=/config/goaccess.conf"

if [ "${INCLUDE_ALL_LOGS:-false}" = true ]; then
  echo -e "\e[33mINCLUDE_ALL_LOGS is enabled. This will likely cause increased memory and cpu usage based on the volume and size of your logs.\e[0m"
  zcat /opt/log/access.log.*.gz | goaccess - /opt/log/access.log /opt/log/access.log.1 $run_args
else
  goaccess - /opt/log/access.log $run_args
fi
