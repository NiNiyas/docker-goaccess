# Docker GoAccess

Based on [GregYankovoy/docker-goaccess](https://github.com/GregYankovoy/docker-goaccess)

If you want unmodified GoAccess build,
see [Github](https://github.com/NiNiyas/goaccess), [DockerHub](https://hub.docker.com/r/niniyas/goaccess). Available
for `amd64, arm/v7, arm64`.
It is much smaller in terms of size.

This is an Alpine linux container which builds GoAccess including GeoIP. It reverse proxies the GoAccess HTML files and
websockets through nginx, allowing GoAccess content to be viewed without any other setup.

## Features

- Uses S6 overlay.
- GoAccess builds from master branch. [allinurl/goaccess](https://github.com/allinurl/goaccess/tree/master).
- Supports `.gz` and `access.log.*` files. Thanks to PR[#16](https://github.com/GregYankovoy/docker-goaccess/pull/16).
- Automatic GeoIP2 city and ASN database updation. Runs every Sunday at 00:00.

## Supported Architectures

| Architecture | Tag   |
|--------------|-------|
| x86-64       | amd64 |
| arm64        | arm64 |
| armhf        | armv7 |

# Usage

## docker run

```
docker run -d --name GoAccess -p 7889:7889 -e MAXMINDDB_LICENSE_KEY=<license-key> -e TZ=Europe/Brussels -e PUID=1000 -e PGID= 1000 -v /path/to/host/nginx/logs:/opt/log -v /path/to/goaccess/storage:/config niniyas/docker-goaccess:amd64 | arm64 | armv7
```

## docker compose

```
version: '3.9'
services:
  goaccess:
    container_name: GoAccess
    #build:                                    #
    #  context: .                              #
    #  dockerfile: Dockerfile                  # - If you want to build.
    #  args:                                   #
    #      OVERLAY_ARCH:                       #
    image: niniyas/docker-goaccess:amd64 | arm64 | armv7
    ports:
      - 7889:7889
    volumes:
      - .config:/config
      - .goaccess/logs:/opt/log
    environment:
      - PUID=1000
      - PGID=1000
      - UMASK=022
      - MAXMIND_LICENSE_KEY=<license-key>
      - TZ=Europe/Brussels
```

## Variables

- MAXMIND_LICENSE_KEY
    - License key to automatically download and update GeoIP2 database. Get it for
      free [here](https://www.maxmind.com/en/accounts/license-key). Optional
- TZ
    - Timezone. View available values [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). Default
      is `Europe/Brussels`. Optional
- PUID
    - User ID. Optional
- PGID
    - Group ID. Optional
- Umask
    - [Wiki](https://en.wikipedia.org/wiki/Umask). Optional
- TINI_VERBOSITY
    - Set to `0` if you want to don't want supress tini output. Default is `0`. Optional
- INCLUDE_ALL_LOGS
    - Include all logs under `/opt/log` such as `.gz` and `access.log.*` files. true|false. Default is `false`. Optional

## Files

- /config/goaccess.conf
    - GoAccess config file (populated with modified config.)
- /config/html
    - GoAccess generated static HTML
- /config/GeoIP
    - GeoIP2 databases and cron log location.

## Volume Mounts

- /config
    - Used to store configuration and GoAccess generated files
- /opt/log
    - Map to nginx log directory

## Reverse Proxy

### nginx

```
    location / {
        proxy_connect_timeout 5m;
        proxy_send_timeout 5m;
        proxy_read_timeout 5m;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Connection "keep-alive";
        proxy_pass_request_headers on;
        proxy_http_version 1.1;

        proxy_pass http://192.168.1.2:7889;
    }
```
