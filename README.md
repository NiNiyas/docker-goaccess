# Docker GoAccess
Fork of [GregYankovoy/docker-goaccess](https://github.com/GregYankovoy/docker-goaccess)

If you want unmodified GoAccess build, see [Github](https://github.com/NiNiyas/goaccess), [DockerHub](https://hub.docker.com/r/niniyas/goaccess). Available for `amd64, arm/v7, arm64`.

This is an Alpine linux container which builds GoAccess including GeoIP.  It reverse proxies the GoAccess HTML files and websockets through nginx, allowing GoAccess content to be viewed without any other setup.

## Difference from original repo
- GoAccess builds from master branch. [allinurl/goaccess](https://github.com/allinurl/goaccess/tree/master)
- Added automatic GeoIP2 city database updation. Runs every Sunday at 00:00.
- Supports `.gz files` and `access.log.*` files. Thanks to [#16](https://github.com/GregYankovoy/docker-goaccess/pull/16).
- Removed PUID and PGID variables. 
- Uses alpine:latest image rather than custom made one.
- Added timezone support.
- Added docker healthcheck.

## Supported Architectures

Pulling [ghcr.io/niniyas/docker-goaccess:latest](https://ghcr.io/niniyas/docker-goaccess) should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

| Architecture | Tag         |
| -----------  | ----------- |
| x86-64       | amd64       |
| arm64        | arm64       |
| armhf        | armv7       |
| armv6        | armv6       |

# Usage
## docker run
```
docker run -d --name GoAccess -p 7889:7889 -e MAXMINDDB_LICENSE_KEY=<license-key> -e TZ=Europe/Brussels -e TINI_VERBOSITY=0 -v /path/to/host/nginx/logs:/opt/log -v /path/to/goaccess/storage:/config niniyas/docker-goaccess:latest 
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
    #      maxmind_license_key: <license-key>  # 
	image: niniyas/docker-goaccess:latest # or niniyas/goaccess:latest if you want smaller image (~6mb). (https://hub.docker.com/r/niniyas/goaccess)
    ports:
      - 7889:7889
    volumes:
      - .config:/config
      - .goaccess/logs:/opt/log
    environment:
      - MAXMINDDB_LICENSE_KEY=<license-key>
      - TZ=Europe/Brussels
      - TINI_VERBOSITY=0 # If you want to supress TINI outputs.
```

## Volume Mounts
- /config
  - Used to store configuration and GoAccess generated files
- /opt/log
  - Map to nginx log directory

## Variables
- MAXMINDDB_LICENSE_KEY
  - License key to automatically update GeoIP2 database. Get it for free [here](https://www.maxmind.com/en/accounts/license-key).
- TZ
  - Timezone. View available values [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). Default is `Europe/Brussels`.

## Files
- /config/goaccess.conf
  - GoAccess config file (populated with modified config.)
- /config/html
  - GoAccess generated static HTML
- /config/data/cron
  - GeoIP2 update log location.

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
