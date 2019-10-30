#!/bin/sh

rm -rf /var/lib/mysql/*
mysqld --initialize-insecure
/etc/init.d/mysql start
mysql -u root -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY 'weNJjOJHpoWzjd3T' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sed -i "s/password.*/password = weNJjOJHpoWzjd3T/g" /etc/mysql/debian.cnf
/etc/init.d/mysql reload