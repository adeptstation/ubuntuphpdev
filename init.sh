#!/bin/sh

# start mysql
/etc/init.d/mysql start
# exec mysqld_safe

# start apache
/usr/sbin/apache2ctl -D FOREGROUND
# source /etc/apache2/envvars
# exec apache2 -D FOREGROUND

