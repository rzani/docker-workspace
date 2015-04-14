#
# APACHE Dockerfile
#
# https://github.com/rzani/docker-workspace

FROM ubuntu:14.10

# File Author
MAINTAINER Rodrigo Zani <rodrigo.zhs@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -yq install curl \
                apache2 \
                libapache2-mod-php5 \
                memcached \
                php5 \
                php5-xdebug \
                php5-dev \
                php5-mysql \
                php5-gd \
                php5-imagick \
                php5-curl \
                php5-mcrypt \
                php5-memcached \
                php5-sqlite \
                php5-odbc \
                php5-pgsql

ENV APACHE_LOG_DIR /var/log/apache2

# Installing Composer
RUN php -r "readfile('https://getcomposer.org/installer');" | php

# Enable apache mod_rewrite
RUN a2enmod rewrite

# Turn display_errors on
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/html_errors = Off/html_errors = On/" /etc/php5/apache2/php.ini

# Enable SSL
RUN /bin/ln -sf ../mods-available/ssl.conf /etc/apache2/mods-enabled/
RUN /bin/ln -sf ../mods-available/ssl.load /etc/apache2/mods-enabled/
RUN /bin/cp /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/

RUN rm -rf /var/lib/apt/lists/*

# Copy entrypoint
COPY ./entrypoint.sh /
RUN chmod 0777 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
