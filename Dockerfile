FROM ubuntu:latest
MAINTAINER James Norman

# Install dependencies
RUN apt-get update
RUN apt-get -y install wget curl
RUN apt-get -y install nginx php5-common php5-cli php5-fpm php5-mysql php-apc php5-imagick php5-imap php5-mcrypt

# Make the directories
RUN mkdir /home/app
RUN mkdir /home/app/build
RUN mkdir /home/app/web

# Setup nginx
ADD build/default /etc/nginx/sites-available/default
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Move files into place
ADD web/ /home/app/web
ADD composer.json /home/app/
ADD build/ /home/app/build

# Install dependencies
WORKDIR /home/app
RUN composer install --prefer-dist

# Expose the port
EXPOSE 80

# Start the server
CMD service php5-fpm start && nginx