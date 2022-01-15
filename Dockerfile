FROM php:8.1-fpm

# Set working directory
WORKDIR /var/www

# Environment variables
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

# Install core dependencies
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y build-essential locales \
        libmemcached-dev \
        libpng-dev libjpeg62-turbo-dev libfreetype6-dev jpegoptim optipng pngquant gifsicle \
        lua-zlib-dev zip unzip \
        git curl && \
    apt-get install -y nginx supervisor

# Add docker-php=extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install php extensions
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions pdo_mysql zip exif pcntl gd memcached opcache

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy startup script
COPY docker/start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

# Copy config files
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/php.ini /usr/local/etc/php/conf.d/app.ini
COPY docker/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/nginx.conf /etc/nginx/sites-enabled/default

# PHP Error Log Files
RUN mkdir /var/log/php
RUN touch /var/log/php/errors.log && chmod 777 /var/log/php/errors.log

EXPOSE 80
ENTRYPOINT ["start-container"]
