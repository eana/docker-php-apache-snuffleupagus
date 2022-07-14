FROM wordpress:6.0.1-php7.4-apache

ENV DEBIAN_FRONTEND noninteractive

# Install git
RUN set -xe && \
    apt-get update && \
    apt-get install --yes git

# renovate: datasource=github-tags depName=jvoisin/snuffleupagus versioning=semver
ENV SNUFFLEUPAGUS_VERSION="v0.8.2"

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
    apt autoremove --yes --purge git && \
    rm -rf /root/snuffleupagus && \
    rm -rf /var/lib/apt/lists/*
