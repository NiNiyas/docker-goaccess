FROM alpine:latest

WORKDIR /usr/src/app

ARG OVERLAY_ARCH
ARG OVERLAY_VERSION=3.2.1.0
ARG GOACCESS_VERSION=1.9.4

ENV CONFIG_DIR="/config" \
    PUID="1000" \
    PGID="1000" \
    UMASK="002" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    TZ=Europe/Brussels

RUN apk update && \
    apk add --no-cache --virtual=build-deps build-base ncurses-dev autoconf automake git gettext-dev libmaxminddb-dev && \
    apk add --no-cache nginx tzdata wget bash shadow grep sed findutils curl xz gawk gzip supercronic logrotate && \
    wget -O - https://github.com/allinurl/goaccess/archive/refs/tags/v${GOACCESS_VERSION}.tar.gz | tar --strip 1 -xzf - && \
    autoreconf -fiv && \
    ./configure --enable-utf8 --enable-geoip=mmdb && \
    make && \
    make install && \
    rm -rf /tmp/goaccess/* /goaccess

COPY /root /

RUN chmod +x /usr/local/bin/goaccess.sh && \
    chmod +x /etc/geoip.sh && \
    cp /opt/nginx-access /etc/logrotate.d/nginx-access && \
    cp /opt/nginx-error /etc/logrotate.d/nginx-error

RUN curl -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar Jpxf - -C / && \
    curl -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.xz | tar Jpxf - -C / && \
    curl -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz  | tar Jpxf - -C / && \
    curl -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz | tar Jpxf - -C /

RUN useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false goaccess && \
    usermod -G users goaccess

EXPOSE 7889
VOLUME [ "/config", "/opt/log" ]

HEALTHCHECK --interval=30s --timeout=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:7889 || exit 1

LABEL org.opencontainers.image.source="https://github.com/NiNiyas/docker-goaccess"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

ENTRYPOINT ["/init"]
