FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV PHP_V=7.3
ENV PMA_V=4.9.1

RUN apt update -y \
    && apt install -y software-properties-common apt-utils \
    && add-apt-repository ppa:ondrej/php \
    && apt update -y \
    && apt upgrade -y

# basic libraries
RUN apt install -y curl wget zip unzip nano git

# apache install
RUN apt install -y apache2 \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && a2enmod rewrite \
    && rm /etc/apache2/sites-enabled/000-default.conf

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

# mysql install
RUN apt install mysql-server -y \
    && /etc/init.d/mysql start \
    && mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';" \
    && mysql -u root -e "FLUSH PRIVILEGES;" 

# php install
RUN apt install -y php${PHP_V} libapache2-mod-php${PHP_V} \
    php${PHP_V}-cli \
    php${PHP_V}-common \
    php${PHP_V}-fpm \
    php${PHP_V}-json \
    php${PHP_V}-pdo \
    php${PHP_V}-mbstring \
    php${PHP_V}-gettext \
    php${PHP_V}-mysql \
    php${PHP_V}-curl \
    php${PHP_V}-gd \
    php${PHP_V}-opcache \
    php${PHP_V}-xdebug \
    php${PHP_V}-zip \
    php${PHP_V}-xml \
    php${PHP_V}-xmlrpc \
    php${PHP_V}-bcmath \
    php${PHP_V}-imagick \
    php${PHP_V}-dev 
    # php7.1-mcrypt

#php mcrypt for older applications
# RUN ln -s /etc/php/7.1/mods-available/mcrypt.ini /etc/php/${PHP_V}/mods-available/ && \
#     phpenmod mcrypt

#php.ini configurations
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/g" /etc/php/${PHP_V}/apache2/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 100M/g" /etc/php/${PHP_V}/apache2/php.ini \
    && sed -i "s/memory_limit = 128M/memory_limit = 512M/g" /etc/php/${PHP_V}/apache2/php.ini

#composer install
RUN curl -sS https://getcomposer.org/installer | php

# install latest phpmyadmin
WORKDIR /tmp
RUN wget https://files.phpmyadmin.net/phpMyAdmin/${PMA_V}/phpMyAdmin-${PMA_V}-english.tar.gz
RUN tar xvf phpMyAdmin-${PMA_V}-english.tar.gz \
    && rm *.tar.gz \
    && mv phpMyAdmin-* /usr/share/phpmyadmin \
    && mkdir -p /var/lib/phpmyadmin/tmp \
    && mkdir /etc/phpmyadmin \
    && cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php \
    && sed -i "s/\['AllowNoPassword'\] = false/\['AllowNoPassword'\] = true/g" /usr/share/phpmyadmin/config.inc.php \
    && sed -i "s/$cfg\['blowfish_secret'\] = ''/$cfg\['blowfish_secret'\] = 'H2OxcGXxflSd8JwrwVlh6KW6s2rER63i'/g" /usr/share/phpmyadmin/config.inc.php \
    && echo "TempDir" >> /usr/share/phpmyadmin/config.inc.php \
    && sed -i "s/TempDir/\$cfg\['TempDir'\] = '\/var\/lib\/phpmyadmin\/tmp';/g" /usr/share/phpmyadmin/config.inc.php

COPY phpmyadmin.conf /etc/apache2/conf-enabled/phpmyadmin.conf

WORKDIR /

#permissions
RUN chown -R www-data:www-data /var/www/html \
    && chown -R mysql:mysql /var/lib/mysql \
    && chown -R www-data:www-data /var/lib/phpmyadmin

VOLUME ["/var/www/html","/var/lib/mysql","/var/log/apache2","/var/log/mysql"]

EXPOSE 80

COPY init.sh /home/init.sh
COPY mysql.sh /home/mysql.sh
RUN chmod u+x /home/init.sh /home/mysql.sh

ENTRYPOINT [ "/home/init.sh" ]