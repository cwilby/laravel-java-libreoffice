FROM php:7.3-alpine

RUN apk add --update \
  curl \
  wget \
  g++ \
  jpegoptim \
  zlib-dev \
  freetype-dev \
  icu-dev \
  jpeg-dev \
  libmcrypt-dev \
  libpng-dev \
  mysql-client \
  postgresql-dev \
  openssl-dev \
  libzip-dev \
  optipng \
  pngquant \
  gifsicle \
  libreoffice \
  libreoffice-writer \
  ttf-dejavu \
  font-noto \
  ttf-freefont \
  ttf-liberation \
  openjdk8-jre \
  make

RUN adduser --system --disabled-password --gecos "" --shell=/bin/bash libreoffice
ADD sofficerc /etc/libreoffice/sofficerc

RUN docker-php-ext-install pdo_mysql pdo_pgsql opcache mysqli \
  && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 \
  && docker-php-ext-install gd \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  && docker-php-ext-configure zip --with-libzip \
  && docker-php-ext-install zip

RUN apk update \
    && pecl channel-update pecl.php.net \
    && apk add --no-cache --update --virtual buildDeps autoconf \
    && apk add libzip-dev zip unzip \
    && php -m | grep -q 'zip' \
    && pecl install -o -f redis \
    && pecl install mongodb bcmath opcache \
    && docker-php-ext-enable redis mongodb

USER root
RUN printf "\n" \
  && apk add imagemagick imagemagick-dev \
  && pecl install imagick mcrypt-1.0.2 \
  && docker-php-ext-enable imagick mcrypt \
  && echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories \
  && apk --no-cache add shadow \
  && usermod -u 1000 www-data

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/

RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

RUN docker-php-ext-install pcntl

RUN . ~/.bashrc

WORKDIR /var/www
