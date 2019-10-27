# Ubuntu LAMPP - Development environment

Dockerfile for PHP development environment in ubuntu

**Software versions**

Ubuntu - 18.04

Apache - 2.4.29

MySql - 5.7.27

PHP - 7.3

PhpMyAdmin - 4.9.1

For support contact **support@adeptstation.com**

**Sample run command**

docker container run -it -d -p 80:80 -v $(pwd):/var/www/html -v mysqldata:/var/lib/mysql --name localhost teamadeptstation/ubuntuphpdev