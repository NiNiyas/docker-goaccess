FROM alpine:latest

ARG build_deps="build-base ncurses-dev autoconf automake git gettext-dev libmaxminddb-dev"
ARG runtime_deps="nginx tini ncurses libintl libmaxminddb tzdata wget bash shadow grep sed"

ARG OVERLAY_ARCH
ARG OVERLAY_VERSION=v2.2.0.3

ENV CONFIG_DIR="/config" \
    PUID="1000" \
    PGID="1000" \
    UMASK="002" \
    ON_DOCKER=True \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    TINI_VERBOSITY=0 \
    TZ=Europe/Brussels \
    INCLUDE_ALL_LOGS=false

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
RUN apk add --update --no-cache ${runtime_deps}

COPY /root /

RUN chmod +x /usr/local/bin/goaccess.sh

# add s6 overlay from https://github.com/linuxserver/docker-baseimage-alpine
ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}-installer /tmp/
RUN chmod +x /tmp/s6-overlay-${OVERLAY_ARCH}-installer && \
    /tmp/s6-overlay-${OVERLAY_ARCH}-installer / && \
    rm /tmp/s6-overlay-${OVERLAY_ARCH}-installer

RUN useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false goaccess && \
    usermod -G users goaccess

EXPOSE 7889
VOLUME [ "/config", "/opt/log" ]

LABEL GITHUB=https://github.com/NiNiyas/docker-goaccess
LABEL MAINTAINER=NiNiyas
LABEL FORKED_FROM=https://github.com/GregYankovoy/docker-goaccess
LABEL org.opencontainers.image.source=https://github.com/NiNiyas/docker-goaccess

HEALTHCHECK --interval=30s --timeout=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:7889 || exit 1

CMD ["/sbin/tini", "-v", "--", "/usr/local/bin/goaccess.sh"]
ENTRYPOINT ["/init"]
