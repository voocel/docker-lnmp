FROM daocloud.io/library/php:7.2-fpm-alpine

COPY config/php.ini /usr/local/etc/php

#RUN apk add autoconf gcc \
#    && wget https://github.com/phpredis/phpredis/archive/3.1.3.tar.gz \
#    && tar -zxvf 3.1.3.tar.gz \
#    && cd phpredis-3.1.3 \
#    && /usr/local/bin/phpize \
#    && ./configure --with-php-config=/usr/local/bin/php-config \
#    && make \
#    && make install \

ENV PHPREDIS_VERSION 4.2.0

RUN cd ~ \
    && wget https://github.com/phpredis/phpredis/archive/4.2.0.tar.gz \
    && tar -zxvf 4.2.0.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-4.2.0 /usr/src/php/ext/redis \
    && docker-php-ext-install redis \

    && apk add libstdc++ libpng-dev \
    && cd ~ \
    && wget https://github.com/swoole/swoole-src/archive/v4.2.12.tar.gz \
    && tar -zxvf v4.2.12.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv swoole-src-4.2.12 /usr/src/php/ext/swoole \
    && docker-php-ext-install swoole \

    && docker-php-ext-install pdo_mysql mysqli pcntl gd\

    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
