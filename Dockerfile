ARG IMAGE_VERSION=3.15

FROM alpine:$IMAGE_VERSION

ARG IMAGE_UID=2000
ARG IMAGE_GID=2000
ARG S6_OVERLAY_VERSION=3.1.3.0

ENV PHP_VERSION=7

COPY manifest /

RUN apk update \
  \
  # install base packages \
  && apk add nginx curl bash gettext tzdata \
  \
  # install php modules and process manager \
  && apk add php${PHP_VERSION} \
  php${PHP_VERSION}-bcmath \
  php${PHP_VERSION}-common \
  php${PHP_VERSION}-ctype \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-dom \
  php${PHP_VERSION}-exif \
  php${PHP_VERSION}-fileinfo \
  php${PHP_VERSION}-fpm \
  php${PHP_VERSION}-gd \
  php${PHP_VERSION}-gmp \
  php${PHP_VERSION}-iconv \
  php${PHP_VERSION}-imap \
  php${PHP_VERSION}-intl \
  php${PHP_VERSION}-json \
  php${PHP_VERSION}-ldap \
  php${PHP_VERSION}-mbstring \
  php${PHP_VERSION}-mcrypt \
  php${PHP_VERSION}-mysqli \
  php${PHP_VERSION}-mysqlnd \
  php${PHP_VERSION}-openssl \
  php${PHP_VERSION}-pcntl \
  php${PHP_VERSION}-pgsql \
  php${PHP_VERSION}-pdo \
  php${PHP_VERSION}-pdo_mysql \
  php${PHP_VERSION}-pdo_pgsql \
  php${PHP_VERSION}-pdo_sqlite \
  php${PHP_VERSION}-pear \
  php${PHP_VERSION}-pecl-memcached \
  php${PHP_VERSION}-pecl-redis \
  php${PHP_VERSION}-phar \
  php${PHP_VERSION}-posix \
  php${PHP_VERSION}-session \
  php${PHP_VERSION}-shmop \
  php${PHP_VERSION}-sqlite3 \
  php${PHP_VERSION}-tokenizer \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-xmlreader \
  php${PHP_VERSION}-xmlwriter \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-zip \
  \
  # add application user \
  && addgroup -S -g $IMAGE_GID phpapp \
  && adduser -S -G phpapp -u $IMAGE_UID phpapp \
  \
  # adjust permissions \
  && mkdir /var/run/s6 \
  && chown -R phpapp:phpapp /run /var/run /var/log/nginx /var/log/php${PHP_VERSION} /var/lib/nginx /etc/nginx /etc/php${PHP_VERSION} /var/www \
  \
  # make timezone adjustable \
  && touch /var/run/s6/localtime /var/run/s6/timezone \
  && rm -f /etc/localtime && ln -s /var/run/s6/localtime /etc/localtime \
  && rm -f /etc/timezone && ln -s /var/run/s6/timezone /etc/timezone \
  \
  # install s6-overlay \
  && curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -o /tmp/s6-overlay-noarch.tar.xz \
  && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
  && curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -o /tmp/s6-overlay-x86_64.tar.xz \
  && tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz \
  \
  # delete default pool file
  && rm -v /etc/php7/php-fpm.d/www.conf

# defaults for s6 service configuration
ENV DOCUMENT_ROOT=/var/www \
  UPLOAD_POST_BODY_MAX_MB=128 \
  NGINX_LISTEN_PORT=8080 \
  PHP_MEMORY_LIMIT_MB=64 \
  PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT" \
  TZ=Europe/Berlin

HEALTHCHECK --interval=20s --timeout=5s --retries=3  CMD curl --fail -s 127.0.0.1:8080/ping

EXPOSE 8080

USER phpapp

# run s6 service supervisor (not as entrypoint!)
ENTRYPOINT [ "/init" ]
