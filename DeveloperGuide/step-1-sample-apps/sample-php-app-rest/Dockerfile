# Dockerfile
FROM php:8.0-apache

RUN apt-get update && apt-get upgrade -y

RUN apt update && apt install -y zlib1g-dev libpng-dev && rm -rf /var/lib/apt/lists/*
RUN apt update && apt install -y curl
RUN apt-get install -y libcurl4-openssl-dev
#RUN apt-get install -y libbz2-1.0:i386
#RUN docker-php-ext-install mysqli pdo_mysql exif gd openssl curl fileinfo
RUN docker-php-ext-install fileinfo
RUN docker-php-ext-install curl
#RUN docker-php-ext-install openssl
RUN docker-php-ext-install mysqli
RUN docker-php-ext-enable mysqli
RUN docker-php-ext-install pdo_mysql

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY start-apache.sh /usr/local/bin

RUN a2enmod rewrite

COPY . /var/www
RUN chown -R www-data:www-data /var/www

RUN chmod 755 /usr/local/bin/start-apache.sh

CMD ["start-apache.sh"]

EXPOSE 80
