#!/bin/sh

set -e

echo -e "Variables set:\\n\
TZ=${TZ}"

# create necessary config dirs if not present
mkdir -p /config/html
mkdir -p /config/data
mkdir -p /config/data/cron
mkdir -p /opt/log

# copy default goaccess config if not present
[ -f /config/goaccess.conf ] || cp /opt/goaccess.conf /config/goaccess.conf
[ -f /config/browsers.list ] || cp /opt/browsers.list /config/browsers.list

# create an empty access.log file so goaccess does not crash if not exist
[ -f /opt/log/access.log ] || touch /opt/log/access.log
[ -f /opt/log/access.log.1 ] || touch /opt/log/access.log.1

/sbin/tini -s -- nginx -c /opt/nginx.conf

if [ -n "$MAXMIND_LICENSE_KEY" ]; then
  cp /etc/geoip.sh /goaccess/geoip.sh
  chmod +x /goaccess/geoip.sh
  echo -e '0 0 * * SUN cd /goaccess && ./geoip.sh >> /config/data/cron/cron.log 2>&1' > /var/spool/cron/crontabs/root
  echo "Using Maxmind license key: ${MAXMIND_LICENSE_KEY}"
  echo "Weekly cron job applied. It runs every Sunday at 00:00."
  /sbin/tini -s -- /usr/sbin/crond -b
else
  echo MAXMIND_LICENSE_KEY variable not found. GeoIP2 db will not update weekly.
fi

/sbin/tini -s -- zcat /opt/log/access.log.*.gz | goaccess - /opt/log/access.log /opt/log/access.log.1 --output /config/html/index.html --real-time-html --log-format=COMBINED --port 7890 --config-file=/config/goaccess.conf --ws-url ws://localhost:7890/ws
