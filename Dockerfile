FROM php:7.2

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp

RUN apt-get update && \
    apt-get install -y libmcrypt-dev git unzip --no-install-recommends && \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN mkdir -p "$COMPOSER_HOME" \
    # install composer
    && php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
    && php -r "if(hash_file('SHA384','/tmp/composer-setup.php')==='93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f'.\
    '115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8'){echo 'Verified';}else{unlink('/tmp/composer-setup.php');}" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/bin --filename=composer  \
    && composer --no-interaction global require 'hirak/prestissimo' \
    && rm -rf /tmp/composer-setup.php /tmp/.htaccess

RUN mkdir /playground && composer create-project laravel/laravel /playground && composer clear-cache

RUN cd /playground && php artisan key:generate

WORKDIR /playground

ENTRYPOINT php /playground/artisan tinker
