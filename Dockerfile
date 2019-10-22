FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV PHP_V=7.2
ENV PMA_V=4.9.1

RUN apt-get update \
    && apt-get upgrade -y

# basic libraries
RUN apt install -y curl wget zip unzip nano git

# apache install
RUN apt install -y apache2 \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && a2enmod rewrite

# mysql install
RUN apt install mysql-server -y \
    && /etc/init.d/mysql start \
    && mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';" \
    && mysql -u root -e "FLUSH PRIVILEGES;"

# php install
RUN apt install -y php libapache2-mod-php php-mbstring php-gettext php-mysql php-curl

#composer install
RUN curl -sS https://getcomposer.org/installer | php

# latest phpmyadmin
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

#permissions
RUN chown -R www-data:www-data /var/www/html \
    && chown -R mysql:mysql /var/lib/mysql \
    && chown -R www-data:www-data /var/lib/phpmyadmin

VOLUME /var/www/html
VOLUME /var/lib/mysql
VOLUME /var/log/apache2
VOLUME /var/log/mysql
VOLUME /etc/apache2

EXPOSE 80

COPY init.sh /home/init.sh
RUN chmod u+x /home/init.sh

ENTRYPOINT [ "/home/init.sh" ]