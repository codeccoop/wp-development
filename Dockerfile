FROM wordpress:latest

ARG DOMAIN
ARG CAPWD
ARG XDEBUG

# System packages
RUN apt update && apt install -y openssl curl less subversion

# PHP extensions
RUN pecl install xdebug
COPY .php/90-xdebug.ini "${PHP_INI_DIR}/conf.d"

# Còdec CA
RUN curl https://oficina.codeccoop.org/nextcloud/s/4Edwn9k3emG2ofJ/download/codec-ca.key > /etc/ssl/private/codec-ca.key
RUN curl https://oficina.codeccoop.org/nextcloud/s/YgZr9mKdRRpoXsz/download/codec-ca.pem > /etc/ssl/private/codec-ca.pem

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

# SSL Config
COPY .ssl/ssl-params.conf /etc/apache2/conf-available/ssl-params.conf
RUN ln -s /etc/apache2/conf-available/ssl-params.conf /etc/apache2/conf-enabled/ssl-params.conf
COPY .ssl/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
RUN ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

# Apache
RUN a2enmod ssl
RUN a2enmod headers
RUN echo "ServerName $DOMAIN" >> /etc/apache2/apache2.conf

# PHP
RUN echo "error_log = /var/log/docker-php.log" >> /usr/local/etc/php/php.ini-development

# WP CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /usr/local/bin/wp

# Install WordPress
RUN cp -rf /usr/src/wordpress/* /var/www/html

# Enable xdebug
RUN test "$XDEBUG" = 'true' && docker-php-ext-enable xdebug

WORKDIR /var/www/html
