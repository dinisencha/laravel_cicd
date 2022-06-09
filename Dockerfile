FROM php:7.2-apache-stretch

LABEL name=phpmjomaa
# Copy composer.lock and composer.json
COPY composer.lock composer.json /srv/app/ 

RUN apt-get update  &&  apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y \
    build-essential \
    mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    dos2unix \
    supervisor \
    nodejs 

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install mbstring pdo pdo_mysql \ 
    && a2enmod rewrite negotiation \
    && docker-php-ext-install opcache


COPY --chown=www-data:www-data . /srv/app 
RUN cp /srv/app/vhost.conf /etc/apache2/sites-available/000-default.conf  && rm /srv/app/vhost.conf

# Install PHP_CodeSniffer
RUN composer global require "squizlabs/php_codesniffer=*" --working-dir=/srv/app
RUN composer  update --working-dir=/srv/app
RUN mv .env.example .env
RUN php artisan key:generate


# Add local and global vendor bin to PATH.
ENV PATH ./vendor/bin:/composer/vendor/bin:/root/.composer/vendor/bin:/usr/local/bin:$PATH

# Change current user to www-data
USER www-data

WORKDIR /srv/app 


