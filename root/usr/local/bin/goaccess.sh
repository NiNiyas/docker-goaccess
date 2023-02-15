#!/bin/bash

set -e

# create necessary config dirs if not present
mkdir -p /config/html
mkdir -p /config/data
mkdir -p /config/data/cron
mkdir -p /config/GeoIP
mkdir -p /opt/log

# copy default goaccess config if not present
[ -f /config/goaccess.conf ] || cp /opt/goaccess.conf /config/goaccess.conf
[ -f /config/browsers.list ] || cp /opt/browsers.list /config/browsers.list

# create an empty access.log file so goaccess does not crash if not exist
[ -f /opt/log/access.log ] || touch /opt/log/access.log

/sbin/tini -s -- nginx -c /opt/nginx.conf

if [ -n "$MAXMIND_LICENSE_KEY" ]; then
  cp /etc/geoip.sh /goaccess/geoip.sh
  chmod +x /goaccess/geoip.sh
  if [ ! -f "/config/GeoIP/GeoLite2-City.mmdb" ]; then
    if [ ! -f "/config/GeoIP/GeoLite2-ASN.mmdb" ]; then
      /bin/bash /goaccess/geoip.sh >>/config/GeoIP/cron.log 2>&1
    fi
  fi
  if ! grep -q "geoip-database /config/GeoIP/GeoLite2-City.mmdb" /config/goaccess.conf; then
    echo "geoip-database /config/GeoIP/GeoLite2-City.mmdb" >> /config/goaccess.conf
    echo "geoip-database /config/GeoIP/GeoLite2-ASN.mmdb" >> /config/goaccess.conf
  fi
  echo -e '0 0 * * SUN cd /goaccess && ./geoip.sh >> /config/GeoIP/cron.log 2>&1' >/var/spool/cron/crontabs/root
  echo "Weekly cron job applied. It runs every Sunday at 00:00."
  /sbin/tini -s -- /usr/sbin/crond -b
else
  if grep -q "geoip-database /config/GeoIP/GeoLite2-City.mmdb" /config/goaccess.conf; then
    grep -v "geoip-database /config/GeoIP/GeoLite2-City.mmdb" /config/goaccess.conf >tmpfile && mv tmpfile /config/goaccess.conf
    grep -v "geoip-database /config/GeoIP/GeoLite2-ASN.mmdb" /config/goaccess.conf >tmpfile && mv tmpfile /config/goaccess.conf
  fi
  echo "MAXMIND_LICENSE_KEY variable not set. GeoIP2 databases will not auto update."
fi

if [ "${INCLUDE_ALL_LOGS:-false}" = true ]; then
  [ -f /opt/log/access.log.1 ] || touch /opt/log/access.log.1
  /sbin/tini -s -- zcat /opt/log/access.log.*.gz | goaccess - /opt/log/access.log /opt/log/access.log.1 --output /config/html/index.html --real-time-html --log-format=COMBINED --port 7890 --config-file=/config/goaccess.conf --ws-url ws://localhost:7890/ws
else
  /sbin/tini -s -- goaccess - /opt/log/access.log --output /config/html/index.html --real-time-html --log-format=COMBINED --port 7890 --config-file=/config/goaccess.conf --ws-url ws://localhost:7890/ws
fi
