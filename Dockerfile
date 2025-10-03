FROM wordpress:latest

ARG DOMAIN
ARG CAPWD

# System packages
RUN apt update && apt upgrade -y
RUN apt install -y openssl curl less subversion mariadb-client

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'ed0feb545ba87161262f2d45a633e34f591ebb3381f2e0063c345ebea4d228dd0043083717770234ec00c5a9f9593792') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# PHPUnit
RUN curl -L -o /usr/local/bin/phpunit \
    https://phar.phpunit.de/phpunit-10.phar \
    && chmod a+x /usr/local/bin/phpunit

# Còdec CA
RUN curl -qL https://oficina.codeccoop.org/nextcloud/s/2iPZKSW86TSRdPH/download/codec-ca.key \
    > /etc/ssl/private/codec-ca.key
RUN curl -qL https://oficina.codeccoop.org/nextcloud/s/D7cAkADMqKDdE6r/download/codec-ca.pem \
    > /etc/ssl/private/codec-ca.pem

# SSL Certificate
RUN echo "authorityKeyIdentifier=keyid,issuer\n\
basicConstraints=CA:FALSE\n\
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n\
subjectAltName = @alt_names\n\
\n\
[alt_names]\n\
DNS.1 = $DOMAIN\n" > /etc/ssl/private/apache-selfsigned.ext

RUN openssl genrsa \
  -out /etc/ssl/private/apache-selfsigned.key 2048

RUN openssl req -new \
  -key /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/private/apache-selfsigned.csr \
  -subj "/C=ES/ST=Catalunya/L=Barcelona/O=Còdec/OU=Developers/CN=$DOMAIN"

RUN openssl x509 \
  -req \
  -in /etc/ssl/private/apache-selfsigned.csr \
  -CA /etc/ssl/private/codec-ca.pem \
  -CAkey /etc/ssl/private/codec-ca.key \
  -CAcreateserial \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -days 3650 \
  -sha256 \
  -extfile /etc/ssl/private/apache-selfsigned.ext \
  -passin pass:$CAPWD

# Apache
RUN a2dissite 000-default

COPY .apache/ssl-params.conf /etc/apache2/conf-available/ssl-params.conf
RUN a2enconf ssl-params

COPY .apache/wp.conf /etc/apache2/sites-available/wp.conf
RUN a2ensite wp

RUN a2enmod ssl
RUN a2enmod headers
RUN echo "ServerName $DOMAIN" >> /etc/apache2/apache2.conf

# PHP
RUN echo "error_log = /var/log/docker-php.log" >> /usr/local/etc/php/php.ini-development

# WP CLI
RUN curl -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Install WordPress
RUN test -z "$(ls -A /var/www/html)" && cp  -rf /usr/src/wordpress/* /var/www/html || echo "wordpress already installed" 

# Enable xdebug
ARG XDEBUG
RUN test "$XDEBUG" = 'yes' || "$XDEBUG" = 'true' \
    && pecl install xdebug || echo 'Without Xdebug'
RUN test "$XDEBUG" = 'yes' || "$XDEBUG" = 'true' \
    && docker-php-ext-enable xdebug || echo 'Without Xdebug'
COPY .php/90-xdebug.ini "${PHP_INI_DIR}/conf.d"

# PHP upload file size
RUN sed -i 's/upload_max_filesize/; upload_max_filesize/' "${PHP_INI_DIR}/php.ini-development"
RUN sed -i 's/upload_max_filesize/; upload_max_filesize/' "${PHP_INI_DIR}/php.ini-production"
RUN sed -i 's/post_max_size/; post_max_size/' "${PHP_INI_DIR}/php.ini-development"
RUN sed -i 's/post_max_size/; post_max_size/' "${PHP_INI_DIR}/php.ini-production"
RUN echo "upload_max_filesize = 40M" >> "${PHP_INI_DIR}/php.ini-development"
RUN echo "upload_max_filesize = 40M" >> "${PHP_INI_DIR}/php.ini-production"
RUN echo "post_max_size = 50M" >> "${PHP_INI_DIR}/php.ini-development"
RUN echo "post_max_size = 50M" >> "${PHP_INI_DIR}/php.ini-production"  

WORKDIR /var/www/html
