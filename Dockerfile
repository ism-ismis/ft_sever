#get base image debian:buster from docker hub
FROM debian:buster

ENV AUTOINDEX on
ENV DEBIAN_FRONTEND noninteractive

#copy SRCS to the container
COPY ./srcs/ /root/

#install all needed packages on debian:buster
#install tools
RUN apt-get -y update \
	&& apt-get -y upgrade \
	&& apt-get install -y wget apt-utils

#install nginx
RUN apt-get install -y nginx

#install db
RUN apt-get install -y mariadb-server

#install php
RUN apt-get install -y \
	php-cli \
	php-fpm \
	php-mysql \
	php \
	php-mbstring \
	php-gd

#set openssl
RUN mkdir /etc/nginx/ssl \
	&& openssl genrsa -out /etc/nginx/ssl/server.key 2048 \
	&& openssl req -new -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.csr \
	-subj '/C=JP/ST=Tokyo/L=Roppongi/O=42Tokyo/CN=localhost' \
	&& openssl x509 -days 365 -req -signkey /etc/nginx/ssl/server.key -in /etc/nginx/ssl/server.csr -out /etc/nginx/ssl/server.crt

# configure nginx
RUN service nginx start \
	&& cp /root/nginx.conf /etc/nginx/sites-available/localhost \
	&& ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/ \
	&& rm /etc/nginx/sites-enabled/default

#install and set phpMyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-english.tar.gz \
	&& tar -xvf phpMyAdmin-5.0.4-english.tar.gz \
	&& mv phpMyAdmin-5.0.4-english/ /var/www/html/phpmyadmin \
	&& mv /root/config.inc.php /var/www/html/phpmyadmin \
	&& mkdir /var/www/html/phpmyadmin/tmp

#install and set wordpress
RUN wget https://wordpress.org/wordpress-5.5.3.tar.gz -P /tmp \
	&& tar -xvf /tmp/wordpress-5.5.3.tar.gz -C /var/www/html \
	&& mv /root/wp-config.php /var/www/html/wordpress

# change user owner & group owner of '/var/www/html/' directory from "root" to "www-data" and give permission
RUN chown -R www-data:www-data /var/www/* \
	&& chmod -R 755 /var/www/*

# configure MySQL
RUN bash root/mysql.sh

# expose HTTP and HTTPS ports
EXPOSE 80 443

# launch script
CMD bash root/start.sh
