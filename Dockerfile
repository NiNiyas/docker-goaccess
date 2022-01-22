FROM alpine:latest

ARG build_deps="build-base ncurses-dev autoconf automake git gettext-dev libmaxminddb-dev"
ARG runtime_deps="nginx tini ncurses libintl libmaxminddb tzdata wget"

ARG maxmind_license_key="build arg"
ARG geolite_city_link="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${maxmind_license_key}&suffix=tar.gz"

ENV TZ Europe/Brussels

WORKDIR /goaccess

# Build goaccess with mmdb geoip
RUN wget -q -O - https://github.com/allinurl/goaccess/archive/refs/heads/master.tar.gz | tar --strip 1 -xzf - && \
    apk add --update --no-cache ${build_deps} && \
    autoreconf -fiv && \
    ./configure --enable-utf8 --enable-geoip=mmdb && \
    make && \
    make install && \
    rm -rf /tmp/goaccess/* /goaccess && \
    apk del $build_deps

# Get necessary runtime dependencies and set up configuration
RUN apk add --update --no-cache ${runtime_deps} && \
    mkdir -p /usr/local/share/GeoIP && \
    wget -q -O- ${geolite_city_link} | tar -xz --strip 1 --directory /usr/local/share/GeoIP && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime

COPY /root /

RUN chmod +x /usr/local/bin/goaccess.sh

EXPOSE 7889
VOLUME [ "/config", "/opt/log" ]

ENTRYPOINT ["/sbin/tini", "-v", "--", "/usr/local/bin/goaccess.sh"]

HEALTHCHECK --interval=30s --timeout=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:7889 || exit 1
