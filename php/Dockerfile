# PHP builder stage - installs dependencies
ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-fpm as builder

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
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

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Final stage
FROM php:${PHP_VERSION}-fpm

# Install runtime dependencies
# PHP 7.4(bullseye)와 8.2(bookworm)는 베이스 OS가 달라 런타임 라이브러리 버전이
# 다르므로(libzip4 vs 5, libicu67 vs 72 등), 패키지명을 고정하지 않고 빌드 스테이지와
# 동일한 -dev 패키지를 설치해 확장(.so)이 요구하는 공유 라이브러리를 버전 자동 매칭한다.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy PHP extensions from builder
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

# Create non-root user for security
RUN useradd -m -s /bin/bash www \
    && mkdir -p /var/www/html \
    && chown -R www:www /var/www/html

# Copy PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/custom.ini
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www/html

# Use non-root user
USER www

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD php -r "exit(0);"

EXPOSE 9000
