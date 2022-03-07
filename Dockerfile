FROM alpine:latest AS builder
LABEL maintainer Naba Das <hello@get-deck.com>
# Add basics first
RUN export DOCKER_BUILDKIT=1
ARG DEPS="\
        php8 \
        php8-phar \
        php8-bcmath \
        php8-calendar \
        php8-mbstring \
        php8-exif \
        php8-ftp \
        composer \
        php8-openssl \
        php8-zip \
        php8-sysvsem \
        php8-sysvshm \
        php8-sysvmsg \
        php8-shmop \
        php8-sockets \
        php8-zlib \
        php8-bz2 \
        php8-curl \
        php8-simplexml \
        php8-xml \
        php8-opcache \
        php8-dom \
        php8-xmlreader \
        php8-xmlwriter \
        php8-tokenizer \
        php8-ctype \
        php8-session \
        php8-fileinfo \
        php8-iconv \
        php8-json \
        php8-posix \
        php8-apache2 \
        php8-pdo \
        php8-pdo_dblib \
        php8-pdo_mysql \
        php8-pdo_odbc \
        php8-pdo_pgsql\
        php8-pdo_sqlite \
        php8-mysqli \
        php8-mysqlnd \
        php8-dev \
        php8-pear \
        curl \
        ca-certificates \
        runit \
        apache2 \
        apache2-utils \
		php8-intl \
		snappy \
        bash \
"

RUN set -x \
    && apk add --no-cache $DEPS \
    && mkdir -p /run/apache2 \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log

# RUN apk --update add --no-cache  openrc nano bash icu-libs openssl openssl-dev gcc make g++ zlib-dev gdbm libsasl snappy php8-intl
RUN apk upgrade

COPY apache/ /
COPY httpd.conf /etc/apache2/httpd.conf
COPY php_ini/php.ini /etc/php8/
WORKDIR /var/www

RUN mv /usr/bin/php8 /usr/bin/php
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/repositories
RUN apk add --no-cache php8-pecl-mongodb
FROM scratch
COPY --from=builder / /
WORKDIR /var/www
RUN chmod +x /etc/service/apache/run
RUN chmod +x /sbin/runit-wrapper
RUN chmod +x /sbin/runsvdir-start

EXPOSE 80

CMD ["/sbin/runit-wrapper"]