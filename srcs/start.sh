#!/bin/bash

sed -i s/AUTOINDEX/$AUTOINDEX/g /etc/nginx/sites-available/localhost

service nginx restart
service mysql restart
service php7.3-fpm start

tail -f /dev/null
