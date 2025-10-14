# PHP 버전 지정
ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-fpm

# 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libsqlite3-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        mysqli \
        gd \
        zip \
        mbstring \
        xml \
        curl \
        opcache \
        bcmath \
        soap \
        sockets \
        exif \
        fileinfo \
        ftp \
        gettext \
        gmp \
        pcntl \
        pdo_sqlite \
        shmop \
        sysvmsg \
        sysvsem \
        sysvshm \
        intl \
        calendar

# Composer 설치
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Composer 버전 확인용 출력 (선택)
RUN composer --version

WORKDIR /www/yc_gomgift