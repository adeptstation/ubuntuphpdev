## Ubuntu LAMPP - *Development environment

Docker for PHP development environment in ubuntu

**Software versions**

- Ubuntu - 18.04
- Apache - 2.4.29
- MySql - 5.7.27
- PHP - 7.3
- PhpMyAdmin - 4.9.1


**Installation steps**

- Use docker-compose or docker run command to setup your container.
- Run mysql.sh in your /home folder to overcome mysql datadir issues.


**Sample run command**

	docker container run -it -d -p 80:80 -v $(pwd):/var/www/html -v mysqldata:/var/lib/mysql --name localhost teamadeptstation/ubuntuphpdev


For further support contact **support@adeptstation.com**