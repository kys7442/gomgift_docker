# PHP 버전 지정
ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-fpm

# 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_mysql

# Composer 설치
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Composer 버전 확인용 출력 (선택)
RUN composer --version
