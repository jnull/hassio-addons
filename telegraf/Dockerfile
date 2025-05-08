ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.21
FROM ${BUILD_FROM}

# # Set shell
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base env
ARG BUILD_ARCH=amd64
ARG TELEGRAF_VERSION="1.34.3"

RUN echo 'hosts: files dns' >> /etc/nsswitch.conf
RUN apk add --no-cache iputils ca-certificates net-snmp-tools procps lm_sensors tzdata su-exec libcap && \
  update-ca-certificates

# Installing telegraf
# RUN ARCH="${BUILD_ARCH}" && \
#   if [ "${BUILD_ARCH}" = "aarch64" ]; then ARCH="arm64"; fi && \
#   if [ "${BUILD_ARCH}" = "armv7" ]; then ARCH="armhf"; fi && \
#   if [ "${BUILD_ARCH}" = "armhf" ]; then ARCH="armel"; fi && \
RUN ARCH= && \
  case "${BUILD_ARCH}" in \
  x86_64) ARCH='amd64';; \
  amd64) ARCH='amd64';; \
  aarch64) ARCH='arm64';; \
  armhf) ARCH='armhf';; \
  armv7) ARCH='armhf';; \
  i386) ARCH='i386';; \
  *) echo "Unsupported architecture: ${BUILD_ARCH}"; exit 1;; \
  esac && \
  set -ex && \
  mkdir ~/.gnupg; \
  echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf; \
  apk add --no-cache --virtual .build-deps wget gnupg tar && \
  for key in \
  9D539D90D3328DC7D6C8D3B9D8FF8E1F7DF8B07E ; \
  do \
  gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys "$key" ; \
  done && \
  wget --no-verbose https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz.asc && \
  wget --no-verbose https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz && \
  gpg --batch --verify telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz.asc telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz && \
  mkdir -p /usr/src /etc/telegraf && \
  tar -C /usr/src -xzf telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz && \
  mv /usr/src/telegraf*/etc/telegraf/telegraf.conf /etc/telegraf/ && \
  mkdir /etc/telegraf/telegraf.d && \
  cp -a /usr/src/telegraf*/usr/bin/telegraf /usr/bin/ && \
  gpgconf --kill all && \
  rm -rf *.tar.gz* /usr/src /root/.gnupg && \
  apk del .build-deps && \
  addgroup -S telegraf && \
  adduser -S telegraf -G telegraf && \
  chown -R telegraf:telegraf /etc/telegraf

# Copy root filesystem
COPY rootfs /
COPY entrypoint.sh /entrypoint.sh

EXPOSE 8092/udp 8094 8125/udp 9273/tcp 25826/udp

# # Labels
# LABEL \
#   maintainer="jnull <admin@jnull.org>" \
#   org.opencontainers.image.title="Home Assistant Add-on: Telegraf add-on" \
#   org.opencontainers.image.description="Telegraf open source data collector" \
#   org.opencontainers.image.vendor="Home Assistant Add-ons by jnull" \
#   org.opencontainers.image.authors="jnull <admin@jnull.org>" \
#   org.opencontainers.image.licenses="MIT License" \
#   org.opencontainers.image.source="https://github.com/jnull/hassio-addons" \
#   org.opencontainers.image.documentation="https://github.com/jnull/hassio-addons/tree/main/telegraf/README.md"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf"]