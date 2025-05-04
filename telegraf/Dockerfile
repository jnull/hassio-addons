ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:7.8.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base system
ARG BUILD_ARCH=amd64
ARG TELEGRAF_VERSION="1.30.2-1"
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  iputils-ping=3:20221126-1+deb12u1 \
  snmp=5.9.3+dfsg-2 \
  lm-sensors=1:3.6.0-7.1 \
  smartmontools=7.3-1+b1 \
  ipmitool=1.8.19-4+deb12u2 \
  procps=2:4.0.2-3 \
  \
  && ARCH="${BUILD_ARCH}" \
  && if [ "${BUILD_ARCH}" = "aarch64" ]; then ARCH="arm64"; fi \
  && if [ "${BUILD_ARCH}" = "armv7" ]; then ARCH="armhf"; fi \
  && if [ "${BUILD_ARCH}" = "armhf" ]; then ARCH="armel"; fi \
  \
  && curl -J -L -o /tmp/telegraf.deb \
  "https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_${ARCH}.deb" \
  && dpkg --install /tmp/telegraf.deb \
  \
  && rm -fr \
  /tmp/* \
  /var/{cache,log}/* \
  /var/lib/apt/lists/*


# Copy root filesystem
COPY rootfs /

# RUN chown root /etc/cont-init.d/telegraf.sh
# RUN chown root /etc/telegraf/telegraf.conf
# RUN chown root /etc/services.d/telegraf/run
# RUN chown root /etc/services.d/telegraf/finish
# RUN chmod 775 /etc/cont-init.d/telegraf.sh
# RUN chmod 775 /etc/telegraf/telegraf.conf
# RUN chmod 775 /etc/services.d/telegraf/run
# RUN chmod 775 /etc/services.d/telegraf/finish

EXPOSE 8092/udp 8094 8125/udp 9273/tcp 25826/udp

# Build arguments
# ARG BUILD_ARCH
# ARG BUILD_DATE
# ARG BUILD_DESCRIPTION
# ARG BUILD_NAME
# ARG BUILD_REF
# ARG BUILD_REPOSITORY
# ARG BUILD_VERSION

# Labels
LABEL \
  maintainer="jnull <admin@jnull.org>" \
  org.opencontainers.image.title="Home Assistant Add-on: Telegraf add-on" \
  org.opencontainers.image.description="Telegraf open source data collector" \
  org.opencontainers.image.vendor="Home Assistant Add-ons by jnull" \
  org.opencontainers.image.authors="jnull <admin@jnull.org>" \
  org.opencontainers.image.licenses="MIT License" \
  org.opencontainers.image.source="https://github.com/jnull/hassio-addons" \
  org.opencontainers.image.documentation="https://github.com/jnull/hassio-addons/tree/main/telegraf/README.md"
