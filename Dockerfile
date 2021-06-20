FROM php:7.4.20-apache

ENV DEBIAN_FRONTEND noninteractive

# System packages
# https://make.wordpress.org/hosting/handbook/handbook/server-environment/#system-packages
RUN set -xe && \
    apt-get update && \
    apt-get install -y \
        ghostscript \
        git \
        imagemagick \
        libc-client-dev \
        libcurl4-openssl-dev \
        libicu-dev \
        libkrb5-dev \
        libonig-dev \
        libpcre2-dev \
        libpng-dev \
        libzip-dev \
        zlib1g-dev

# PHP extensions for WordPress
# https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions
RUN set -xe && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install exif && \
    docker-php-ext-install gd && \
    docker-php-ext-install intl && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install zip

# Install snuffleupagus
# Check latest stable version here: https://github.com/jvoisin/snuffleupagus/releases
ENV SNUFFLEUPAGUS_VERSION v0.7.0
# Add snuffleupagus configuration
COPY snuffleupagus/20-snuffleupagus.ini $PHP_INI_DIR/conf.d/
# Add my custom snuffleupagus rules to the container
COPY snuffleupagus/snuffleupagus.rules $PHP_INI_DIR
# Add my custom PHP config to the container.
COPY snuffleupagus/99-php-custom.ini $PHP_INI_DIR/conf.d/99-php-custom.ini
RUN set -xe && \
    git clone https://github.com/jvoisin/snuffleupagus.git /root/snuffleupagus && \
    cd /root/snuffleupagus/ && \
    git checkout -b ${SNUFFLEUPAGUS_VERSION} ${SNUFFLEUPAGUS_VERSION} && \
    cd src/ && \
    phpize && \
    ./configure --enable-snuffleupagus && \
    make && \
    make install

# Clean up
RUN set -xe && \
    rm -rf /root/snuffleupagus && \
    rm -rf /var/lib/apt/lists/*

# Enable mod-rewrite
RUN set -xe && \
    a2enmod rewrite
