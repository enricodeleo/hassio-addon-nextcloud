ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG C.UTF-8
# ENV NEXTCLOUD_DATA_DIR /share/nextcloud

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y jq smbclient \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Change the root folder for Nextcloud to the /share directory to be persistent
RUN  sed -i "s|/var/www|/share/nextcloud|g" /etc/apache2/sites-enabled/000-default.conf \
  && sed -i "s|/var/www|/share/nextcloud|g" /etc/apache2/apache2.conf \
  && sed -i "s|/var/www/html|/share/nextcloud/html|g" /entrypoint.sh \
  && sed -i "s|/var/www/html|/share/nextcloud/html|g" /usr/src/nextcloud/config/autoconfig.php

RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf && a2enconf fqdn

# Copy data
COPY init /
RUN chmod a+x /init

ENTRYPOINT [ "/init" ]
CMD ["apache2-foreground"]

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
  io.hass.name="Nextcloud" \
  io.hass.description="Nextcloud Home Assistant add-on" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  io.hass.version=${BUILD_VERSION} \
  maintainer="Enrico Deleo <hello@enricodeleo.com>" \
  org.label-schema.description="Nextcloud Home Assistant add-on" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="Nextcloud" \
  org.label-schema.schema-version="1.0.0" \
  org.label-schema.url="https://github.com/enricodeleo/hassio-addon-nextcloud" \
  org.label-schema.usage="https://github.com/enricodeleo/hassio-addon-nextcloud/tree/master/nextcloud/README.md" \
  org.label-schema.vcs-ref=${BUILD_REF} \
  org.label-schema.vcs-url="https://github.com/enricodeleo/hassio-addon-nextcloud/" \
  org.label-schema.vendor="Enrico Deleo"