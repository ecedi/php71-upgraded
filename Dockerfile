FROM php:7.1-apache

RUN sed -ri -e 's!/var/www/html!/var/www/html/web!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!/var/www/html/web!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt-get update && \
    apt-get install -y curl \
    acl \
    zsh \
    sudo \
    git \
    unzip \
    npm \
    net-tools \
    wget \
    vim \
    zlib1g-dev \
    libicu-dev \
    g++ \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssh2-1-dev \
    libssh2-1 \
    rsync \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-configure exif \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && npm install -g yarn

RUN pecl install ssh2-1.1.2 xdebug-2.7.2 \
    && docker-php-ext-enable ssh2 xdebug \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN wget -O composer.phar https://getcomposer.org/composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

ENV COMPOSER_MEMORY_LIMIT=-1

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN sed -ri -e 's!^memory_limit.*!memory_limit = -1!g' "$PHP_INI_DIR/php.ini"

ENTRYPOINT [".docker/scripts/deploy.sh"]
