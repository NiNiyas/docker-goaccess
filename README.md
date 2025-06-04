# Docker GoAccess

This is an Alpine linux container which builds GoAccess including GeoIP. It reverse proxies the GoAccess HTML files and websockets through nginx.

This is readily available to use with [SWAG](https://github.com/linuxserver/docker-swag). However, with some configuration tweaks, it can likely be adapted for use with other frameworks.

Based on [GregYankovoy/docker-goaccess](https://github.com/GregYankovoy/docker-goaccess)

## Setup

### Supported Architectures

Simply pulling `ghcr.io/niniyas/docker-goaccess:latest` should retrieve the correct image for your arch, but you can
also pull specific arch images via tags.

| Architecture | Tag   |
|--------------|-------|
| amd64        | amd64 |
| arm64        | arm64 |


### Docker Compose (recommended)

```yaml
version: '3.9'
services:
  goaccess:
    container_name: GoAccess
    #build:                                    #
    #  context: .                              #
    #  dockerfile: Dockerfile                  # - If you want to build.
    #  args:                                   #
    #      OVERLAY_ARCH:                       #
    image: ghcr.io/niniyas/docker-goaccess:latest
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
      - INCLUDE_ALL_LOGS=true
      - TZ=Europe/Brussels
```

### Docker CLI

```shell
docker run -d \
    --name=GoAccess \
    -e PORT=9994 \
    -e PUID=1000 \
    -e PGID=1000 \
    -e UMASK=002 \
    -e MAXMINDDB_LICENSE_KEY=<license-key> \
    -e INCLUDE_ALL_LOGS=true \
    -p 7889:7889/tcp \
    -v /path/to/data:/config \
    -v /path/to/host/nginx/logs:/opt/log
    ghcr.io/niniyas/docker-goaccess:latest
```

### Available environment variables

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
- INCLUDE_ALL_LOGS
    - Include all logs under `/opt/log` such as `access.log.*` files. true|false. Default is `false`. Optional
