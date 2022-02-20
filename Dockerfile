FROM alpine:latest

ARG build_deps="build-base ncurses-dev autoconf automake git gettext-dev libmaxminddb-dev"
ARG runtime_deps="nginx tini ncurses libintl libmaxminddb tzdata wget bash shadow"

ARG OVERLAY_ARCH
ARG MAXMIND_LICENSE_KEY
ARG OVERLAY_VERSION=v2.2.0.3
ARG GEOLITE_CITY="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"

ENV TZ Europe/Brussels
ENV TINI_SUBREAPER=

WORKDIR /goaccess

# Build goaccess with mmdb geoip
RUN wget -q -O - https://github.com/allinurl/goaccess/archive/refs/heads/master.tar.gz | tar --strip 1 -xzf - && \
    apk add --update --no-cache ${build_deps} && \
    autoreconf -fiv && \
    ./configure --enable-utf8 --enable-geoip=mmdb && \
    make && \
    make install && \
    rm -rf /tmp/goaccess/* /goaccess && \
    apk del --purge $build_deps

# Get necessary runtime dependencies and set up configuration
RUN apk add --update --no-cache ${runtime_deps} && \
    mkdir -p /usr/local/share/GeoIP && \
    wget -q -O- ${GEOLITE_CITY} | tar -xz --strip 1 --directory /usr/local/share/GeoIP && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime

COPY /root /

RUN chmod +x /usr/local/bin/goaccess.sh

# add s6 overlay from https://github.com/linuxserver/docker-baseimage-alpine
ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}-installer /tmp/
RUN chmod +x /tmp/s6-overlay-${OVERLAY_ARCH}-installer && \
    /tmp/s6-overlay-${OVERLAY_ARCH}-installer / && \
    rm /tmp/s6-overlay-${OVERLAY_ARCH}-installer

RUN addgroup -S goaccess && adduser -S goaccess -G goaccess

EXPOSE 7889
VOLUME [ "/config", "/opt/log" ]

LABEL GITHUB=https://github.com/NiNiyas/docker-goaccess
LABEL MAINTAINER=NiNiyas
LABEL FORKED_FROM=https://github.com/GregYankovoy/docker-goaccess
LABEL org.opencontainers.image.source https://github.com/NiNiyas/docker-goaccess

HEALTHCHECK --interval=30s --timeout=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:7889 || exit 1

CMD ["/sbin/tini", "-v", "--", "/usr/local/bin/goaccess.sh"]
ENTRYPOINT ["/init"]
